({
  toggleModal: function(component) {
    this.toggleElement(component, "modal-dialog");
    this.toggleElement(component, "modal-backdrop");
  },

  toggleElement: function(component, name) {
    var element = component.find(name);
    if (element) {
      $A.util.toggleClass(element, "slds-hide");
    }
  },
  
  saveAndToggleModal: function(component) {
    var helper = this;
    var saveAddressAction = component.get("c.persistAddress");
    var address = component.get("v.selectedAddress");
    var recordId = component.get("v.recordId");
    var addressType = component.get("v.selectedAddressType");
    saveAddressAction.setParams( { address: JSON.stringify(address), addressType: addressType , recordId: recordId } );
    saveAddressAction.setCallback(this, function(response) {
      helper.saveAddressCallback(response, helper, component);
    });
    $A.enqueueAction(saveAddressAction);
  },
  
  saveAddressCallback: function(response, helper, component) {
    var state = response.getState();
    var toast;
    if(state !== "SUCCESS") {
      toast = { "title": "Failed To Save", "message": "The address could not be saved at this time."};
      console.error('Problem saving address', response.getError()[0] );
      helper.fireToast(toast);
    }
    else {
      toast = { "title": "Address Saved", "message": "The AddressFinder-verified address was successfully saved."};
      helper.toggleModal(component);
      helper.fireToast(toast);
      $A.get("e.force:refreshView").fire();
    }
  },
  
  fireToast: function(toastParams) {
    var resultsToast = $A.get("e.force:showToast");
    resultsToast.setParams(toastParams);
    resultsToast.fire();
  },

  createAction: function(component, serverMethod, variableName, flagName, shouldAlert) {
    var action = component.get(serverMethod);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var key = response.getReturnValue();
        if (key !== null) {
          component.set(variableName, key);
          this.actionSucceeded(flagName, component);
        } else if (shouldAlert) {
          throw new Error("'" + variableName + "' has not been set for the AddressFinder widget.\n This can be set by an administrator in the AddressFinder Config\nSetup -> Custom Settings -> AddressFinder Config -> Manage -> New");
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error(variableName, "Error message: " + errors[0].message);
          }
        } else {
          console.error(variableName, "Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  checkForRequirements: function(component) {
    if (component.get("v.afKey") && 
    component.get("v.countryCode") && 
    component.get("v.isKeyRetrieved") === true && 
    component.get("v.isCountryCodeRetrieved") === true && 
    component.get("v.isVersionRetrieved") === true && 
    component.get("v.isRetrieved") === true && 
    component.get("v.isRendered") === true) {
      this.setupWidget(component);
    }
  },

  actionSucceeded: function(flagName, component) {
    component.set(flagName, true);
    this.checkForRequirements(component);
  },

  setupWidget: function(component) {
    if (component.get("v.isWidgetSetup") === false) {
      var key = component.get("v.afKey");
      var countryCode = component.get("v.countryCode");
      var version = component.get("v.version");
      var street = document.querySelector("#input-street");
      var widget = new AddressFinder.Widget(street,
        key,
        countryCode, {
          show_addresses: false
        });
      this.addWidgetService(widget, countryCode, key, component, version);
      component.set("v.isWidgetSetup", true);
    }
  },

  addWidgetService: function(widget, countryCode, key, component, version) {
    var base_url = 'https://api.addressfinder.io/api/' + countryCode + '/address?key=' + key + '&format=json&widget_token=aaddcfa38b26e65330108190dd642a79f2ce04b738a68077dd28f15eb81d9f237ccbdea9b982a9d1ef09ecbb7eb5d67b463a96a36390aaf9325db2d93cf52a0z&sfv=' + version;
    var service = widget.addService('store-search', function(query, response_fn) {
      var url = base_url + '&q=' + query;

      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function(event) {
        if (xhr.readyState === 4) {
          if (xhr.status === 200) {
            var response = JSON.parse(xhr.response);

            var results = response.completions.map(function(item) {
              return {
                value: item.a,
                data: item.pxid
              };
            });
            response_fn(query, results);
          } else {
            console.error(xhr);
            console.error(xhr.status);
          }
        }
      };

      xhr.open('GET', url, true);
      xhr.send(null);
    });
    this.setServiceOptions(service, component, base_url, countryCode);
  },

  setServiceOptions: function(service, component, base_url, countryCode) {
    var helper = this;
    service.setOption("renderer", function(value) {
      return "<li>" + value + "</li>";
    });

    service.on("result:select", function(value, data) {
      var url = base_url.replace('/address', '/address/info') + '&pxid=' + data;
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function(event) {
        if (xhr.readyState === 4) {
          if (xhr.status === 200) {
            helper.setAddress(JSON.parse(xhr.response), countryCode, component);
          } else {
            console.error(xhr);
            console.error(xhr.status);
          }
        }
      };

      xhr.open('GET', url, true);
      xhr.send(null);

    });
  },
  
  setAddress: function(response, countryCode, component) {
    var country = (countryCode === 'nz' ? "New Zealand" : "Australia");
    this.setFieldValue("country", country, component);
    var addr = response.a;

    // get full address string from widget result
    var addressComponents = addr.split(', ');
    var componentCount = addressComponents.length;

    //Split out the street address and format it
    var street = addressComponents.slice(0, componentCount - 1).join('\n');
    this.setFieldValue("street", street, component);

    //Split out the city and postalCode
    var cityAndPostcode = addressComponents[componentCount - 1].split(' ');
    var city = cityAndPostcode.slice(0, cityAndPostcode.length - 1).join(' ');
    var postalCode = cityAndPostcode[cityAndPostcode.length - 1];
    this.setFieldValue("city", city, component);
    this.setFieldValue("postalCode", postalCode, component);
   	var state = response.region;
    this.setFieldValue("state", state, component);
    this.setAddressVariable(street, city, postalCode, state, country, component);
  },
    
    setAddressVariable: function(street, city, postalCode, state, country, component) {
        var addr = new Object();
        addr.street = street;
        addr.city = city;
        addr.postalCode = postalCode;
        addr.state = state;
        addr.country = country;
        component.set('v.selectedAddress', addr);
    },

  setFieldValue: function(elementId, fieldValue, component) {
    var field = document.querySelector("#input-" + elementId);
    if (field) {
      field.value = fieldValue;
    }
    else {
      console.error('Field ID: ' + elementId + '\nValue: ' + fieldValue + ' could not be found.\n');
    }
  },

  getRecordAddresses: function(component) {
    var helper = this;
    var recordId = component.get("v.recordId");
    
    var action = component.get("c.fetchRecordAddresses");
    action.setParams({ recordId: recordId, aggregated: true });
    action.setCallback(this, function(a) {
      component.set("v.addresses", a.getReturnValue());
    	helper.actionSucceeded("v.isRetrieved", component);
    });
    $A.enqueueAction(action);
  },
  
  renderAction: function(component) {
    if(document.querySelector("#input-street")) {
      this.actionSucceeded("v.isRendered", component);
    }
  },
  
  getAddressTypes: function(component) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getAddressTypesForRecord");
    action.setParams({ recordId: recordId });
    
    action.setCallback(this, function(a) {
      component.set("v.addressTypes", a.getReturnValue());
    });
    $A.enqueueAction(action);
  },
  
  onAddressTypeChange: function(component, event) {
    var addressType = event.getSource().get("v.value");
    component.set("v.selectedAddressType",  addressType);
    var addresses = component.get("v.addresses");
    component.set("v.selectedAddress", addresses[addressType]);
    component.find("edit").set("v.disabled", (addressType == null));
  },

})