({
	doInit : function(component, event, helper) {

		helper.populateGeneratedAttributes(component);

		helper.fetchRecords(component, function() {

			helper.buildFilterMenus(component, false);
		});
	},

	filterChosen : function(component, event, helper) {
		console.log('filterChosen', event.getSource().getLocalId(), event.getParam('value'));

		let fieldName = event.getSource().getLocalId(), value = event.getParam('value'), context = component.get('v.context');
		if('--all--' === value)
			delete context.activeFilters[fieldName];
		else
			context.activeFilters[fieldName] = value;
		component.set('v.context', context, false);

		helper.fetchRecords(component, function() {

			helper.buildFilterMenus(component, true);
		});
	}
});