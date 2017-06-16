({
    afterScriptsLoaded : function(component, event, helper) {
       component.set("v.isScriptLoaded", true);
       if(component.get("v.isRendered") === true) {
            helper.setupWidget(component);
        }
    },
    
    handleDoneRendering : function(component, event, helper) {
        component.set("v.isRendered", true);
       if(component.get("v.isScriptLoaded") === true) {
            helper.setupWidget(component);
        }
    }
})