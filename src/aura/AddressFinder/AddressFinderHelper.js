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
    var saved = this.saveAddress();
    if(saved) {
      this.toggleModal(component);
    }
    this.fireToast(saved);
  },
  
  saveAddress: function(component) {
    
  },
  
  fireToast: function(success) {
    var toastParams = this.getSaveToastParams(saved);
    var resultsToast = $A.get("e.force:showToast");
    resultsToast.setParams(toastParams);
    resultsToast.fire();
  },
  
  getSaveToastParams: function(success) {
    if(success) {
      return { "title": "Address Saved", "message": "The AddressFinder-verified address was successfully saved."};
    }
    return { "title": "Failed To Save", "message": "The address could not be saved at this time."};
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
        console.debug("AF-KEY-onreadystatechange");
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
    service.setOption("renderer", function(value) {
      return "<li>" + value + "</li>";
    });

    service.on("result:select", function(value, data) {
      console.debug("AF-result:select");
      var url = base_url.replace('/address', '/address/info') + '&pxid=' + data;
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function(event) {
        console.debug("AF-onreadystatechange", xhr.readyState);
        if (xhr.readyState === 4) {
          console.debug("AF-4");
          if (xhr.status === 200) {
            console.debug("AF-200");
            setAddress(JSON.parse(xhr.response), countryCode);
          } else {
            console.error(xhr);
            console.error(xhr.status);
          }
        }
      };

      xhr.open('GET', url, true);
      xhr.send(null);

      function setAddress(response, countryCode) {
        console.debug("AF-setAddress");
        setFieldValue("#input-country", countryCode === 'nz' ? "New Zealand" : "Australia");
        var address = response.a;

        // get full address string from widget result
        var addressComponents = address.split(', ');
        var componentCount = addressComponents.length;

        //Split out the street address and format it
        var streetAddress = addressComponents.slice(0, componentCount - 1).join('\n');
        setFieldValue("#input-street", streetAddress);

        //Split out the city and postcode
        var cityAndPostcode = addressComponents[componentCount - 1].split(' ');
        var city = cityAndPostcode.slice(0, cityAndPostcode.length - 1).join(' ');
        var postcode = cityAndPostcode[cityAndPostcode.length - 1];
        setFieldValue("#input-city", city);
        setFieldValue("#input-postalCode", postcode);

        setFieldValue("#input-state", response.region);
      }

      function setFieldValue(elementId, fieldValue) {
        console.debug("AF-setFieldValue", elementId);
        var field = document.querySelector(elementId);
        if (field) {
          field.value = fieldValue;
          return;
        }
        else {
          console.error('Field ID: ' + elementId + '\nValue: ' + fieldValue + ' could not be found.\n');
        }
      }
    });
  },

  getRecord: function(component) {
    var helper = this;
    var fields = component.get("v.fieldsToShow");
    var recordId = component.get("v.recordId");
    var action = component.get("c.fetchRecord");
    var fieldList = fields.split(',');
    var fieldMap = new Object();
    component.set("v.fieldList", fieldList);
    action.setParams({
      recordId: recordId,
      fieldsToShow: fields
    });
    
    action.setCallback(this, function(a) {
      component.set("v.detailRecord", a.getReturnValue().Address);
      helper.actionSucceeded("v.isRetrieved", component);
    });
    $A.enqueueAction(action);
  },
  
  renderAction: function(component) {
    if(document.querySelector("#input-street")) {
      this.actionSucceeded("v.isRendered", component);
    }
  },
  
  // setAddress: function(address) {
  //   this.setAddressToInput("#input-street", address.street);
  //   this.setAddressToInput("#input-city", address.city);
  //   this.setAddressToInput("#input-country", address.country);
  //   this.setAddressToInput("#input-state", address.state);
  //   this.setAddressToInput("#input-postalCode", address.postalCode);
  // },
  // 
  // setAddressToInput: function(inputName, value) {
  //   var element = document.getElementById(inputName);
  //   if(element && value !== null) {
  //     element.value = value;
  //   }
  // }

})