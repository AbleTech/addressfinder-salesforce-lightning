({  
    createAction : function(component, serverMethod, variableName, flagName, shouldAlert) {
      var action = component.get(serverMethod);
      action.setCallback(this, function(response) {
        var state = response.getState();
            if (state === "SUCCESS") {
              var key = response.getReturnValue();
              if(key !== null) {
                component.set(variableName, key);
                this.actionSucceeded(flagName, component);
              }
              else if(shouldAlert) {
                alert("'" + variableName + "' has not been set for the AddressFinder widget.\n This can be set by an administrator in the AddressFinder Config\nSetup -> Custom Settings -> AddressFinder Config -> Manage -> New");
              }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                      console.error(variableName, "Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.error(variableName, "Unknown error");
                }
            }
      });
      $A.enqueueAction(action);
    },
    
    checkForRequirements : function(component) {
        if(component.get("v.afKey") && component.get("v.countryCode") && component.get("v.isKeyRetrieved") === true && component.get("v.isCountryCodeRetrieved") === true) {
          this.setupWidget(component);
        }
      },
    
    actionSucceeded : function(flagName, component) {
      component.set(flagName, true);
      this.checkForRequirements(component);
    },
    
    setupWidget : function(component) {
        if(component.get("v.isWidgetSetup") === false) {
            console.debug("setupWidget");
            var fieldSet = document.querySelector("fieldset.forceInputAddress");
            if(fieldSet) {
                var addrIdMap = this.makeAddressElementMap(fieldSet); 
                var key = component.get("v.afKey");
                var countryCode = component.get("v.countryCode");
                var widget = new AddressFinder.Widget(document.getElementById(addrIdMap["streetId"]), 
                                                      key, 
                                                      countryCode, 
                                                      { show_addresses: false });        
                this.addWidgetService(widget, countryCode, key, addrIdMap);
                component.set("v.isWidgetSetup", true);
            }
        }
    },
    
    addWidgetService : function(widget, countryCode, key, addrIdMap) {
        var service = widget.addService('store-search', function(query, response_fn) {
            var url = 'https://api.addressfinder.io/api/'+ countryCode +'/address?key=' + key + '&format=json&q=' + query;
            
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(event) {
                if (xhr.readyState == 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.response);
                        
                        var results = response.completions.map(function(item){
                            return {value: item.a, data: item.pxid};
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
        this.setServiceOptions(service, countryCode, key, addrIdMap);
    },
    
    setServiceOptions : function(service, countryCode, key, addrIdMap) {        
        service.setOption("renderer", function(value) {
            return "<li>" + value + "</li>";
        });
        
        service.on("result:select", function(value, data) {
            var url = 'https://api.addressfinder.io/api/'+ countryCode +'/address/info?key=' + key + '&format=json&pxid=' + data;
            
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(event) {
                if (xhr.readyState == 4) {
                    if (xhr.status === 200) {                        
                        var response = JSON.parse(xhr.response);
                        setFieldValue(addrIdMap["streetId"], response.postal_line_1 );
                        setFieldValue(addrIdMap["cityId"], response.city);
                        setFieldValue(addrIdMap["provinceId"], response.region);
                        setFieldValue(addrIdMap["postcodeId"], response.postcode);
                        setFieldValue(addrIdMap["countryId"], countryCode === 'nz' ? "New Zealand" : "Australia");
                        
                    } else {
                        console.error(xhr);
                        console.error(xhr.status);
                    }
                }
            };
            
            xhr.open('GET', url, true);
            xhr.send(null);
            
            function setFieldValue(elementId, value) {
                var field = document.getElementById(elementId);
                if (field) {
                    field.value = value;
                    return;
                }
                console.error('Field ID: ' + elementId + '\nValue: ' + value + ' could not be found.\n');
            }
        });
    },
    
    makeAddressElementMap : function(addressFieldSet) {
        var addrIdMap = {};
        if(addressFieldSet != null) {
            for (let type of ["textarea", "input"]) {
                var typeInputs = addressFieldSet.querySelectorAll(type);
                for(var field of typeInputs) {
                    var map =  { streetId: "STREET", cityId: "CITY", provinceId: "STATE", postcodeId: "CODE", countryId: "COUNTRY" };
                    for (var key in map) {
                        var placeholderValue = map[key];
                        if (field.placeholder.toUpperCase().includes(placeholderValue)) {
                            addrIdMap[key] = field.id;
                            console.debug(placeholderValue);
                            break;
                        }
                    }
                }
            }
        }
        return addrIdMap;
    }
    
})