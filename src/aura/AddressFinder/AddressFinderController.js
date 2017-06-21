({
    afterScriptsLoaded : function(component, event, helper) {
      helper.actionSucceeded("v.isScriptLoaded", component);
    },

    handleDoneRendering : function(component, event, helper) {
      var hasAlreadyBeenRendered = component.get("v.isRendered");
      if(!hasAlreadyBeenRendered) {
        var variable = component.get("v.addressFieldSet");
        var fieldSet = document.querySelector(variable);
        if(fieldSet) {
          helper.actionSucceeded("v.isRendered", component);
          helper.createAction(component, "c.getConfigKey", "v.afKey", "v.isKeyRetrieved", true);
          helper.createAction(component, "c.getConfigCountryCode", "v.countryCode", "v.isCountryCodeRetrieved", false);
        }
      }
    }
})