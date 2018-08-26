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
		component.set('v.context', context, false); // don't bother to redraw yet, wait for the server response

		context.currentPage = 1; // reset to the first page

		helper.fetchRecords(component, function() {

			helper.buildFilterMenus(component, true);
		});
	},

	changePageSize : function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = 1; // reset to the first page
		// no need to set pageSize since it was value bound to the lightning:select

		helper.fetchRecords(component);
	},

	nextPage: function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = context.currentPage + 1;

		helper.fetchRecords(component);
	},

	previousPage: function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = context.currentPage - 1;

		helper.fetchRecords(component);
	}
});