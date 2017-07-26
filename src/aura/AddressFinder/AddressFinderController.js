({
  afterScriptsLoaded: function(component, event, helper) {
    helper.actionSucceeded("v.isScriptLoaded", component);
    helper.createAction(component, "c.getConfigKey", "v.afKey", "v.isKeyRetrieved", true);
    helper.createAction(component, "c.getConfigCountryCode", "v.countryCode", "v.isCountryCodeRetrieved", false);
    helper.createAction(component, "c.getAppVersion", "v.version", "v.isVersionRetrieved", false);
  },

  openModal: function(component, event, helper) {
    helper.toggleModal(component);
  },

  closeModal: function(component, event, helper) {
    helper.toggleModal(component);
  },

  saveAndClose: function(component, event, helper) {
    helper.saveAndToggleModal(component);
  },
  
  doInit: function(component, event, helper) {
    helper.getRecord(component);
  },
})