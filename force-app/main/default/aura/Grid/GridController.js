({
	doInit : function(component, event, helper) {

		helper.populateGeneratedAttributes(component);

		helper.fetchRecords(component, function() {

			helper.buildFilterMenus(component, false);
		});
	},

	doSearch : function(component, event, helper) {

		helper.fetchRecords(component);
	},

	checkForSearchEnter : function(component, event, helper) {

		// if the user hit the enter key
		if(event.which === 13)
			helper.fetchRecords(component);
	},

	clearSearch : function(component, event, helper) {

		let context = component.get('v.context');
		context.searchTerm = '';
		component.set('v.context', context);

		helper.fetchRecords(component);
	},

	filterChosen : function(component, event, helper) {
		console.log('filterChosen', event.getSource().getLocalId(), event.getParam('value'));

		let fieldName = event.getSource().getLocalId(), value = event.getParam('value'), context = component.get('v.context');
		if('--all--' === value)
			delete context.activeFilters[fieldName];
		else
			context.activeFilters[fieldName] = value;
		context.currentPage = 1; // reset to the first page
		component.set('v.context', context, false); // don't bother to redraw yet, wait for the server response

		helper.fetchRecords(component, function() {

			helper.buildFilterMenus(component, true);
		});
	},

	changeSort : function(component, event, helper) {

		let context = component.get('v.context');

		context.sortedBy = helper.extractFieldName(event.target);
		context.sortedDirection = context.sortedDirection === 'ASC' ? 'DESC' : 'ASC';
		context.currentPage = 1; // reset to the first page
		component.set('v.context', context);

		helper.fetchRecords(component);
	},

	changePageSize : function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = 1; // reset to the first page
		// no need to set pageSize since it was value bound to the lightning:select

		helper.fetchRecords(component);
	},

	nextPage : function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = context.currentPage + 1;

		helper.fetchRecords(component);
	},

	previousPage : function(component, event, helper) {

		let context = component.get('v.context');
		context.currentPage = context.currentPage - 1;

		helper.fetchRecords(component);
	}
});