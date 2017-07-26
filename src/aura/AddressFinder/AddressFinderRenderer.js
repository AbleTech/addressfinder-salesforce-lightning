({
	afterRender: function (component, helper) {
    this.superAfterRender();
		helper.renderAction(component);
  },
  
  rerender: function (component, helper) {
    this.superRerender();
		helper.renderAction(component);
  },
})