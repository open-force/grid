({
	doInit : function(component, event, helper) {

		helper.populateGeneratedAttributes(component);

		helper.fetchRecords(component, true, false);
	},

	doSearch : function(component, event, helper) {

		helper.fetchRecords(component, true, true);
	},

	checkForSearchEnter : function(component, event, helper) {

		// if the user hit the enter key
		if(event.which === 13)
			helper.fetchRecords(component, true, true);
	},

	clearSearch : function(component, event, helper) {

		let context = component.get('v.context');
		context.searchTerm = '';
		component.set('v.context', context);

		helper.fetchRecords(component, true, true);
	},

	filterChosen : function(component, event, helper) {

		let fieldName = event.getSource().getLocalId(), value = event.getParam('value');

		if('--all--' === value)
			helper.clearFilter(component, fieldName);
		else
			helper.addFilter(component, fieldName, value);
	},

	clearFilter : function(component, event, helper) {

		let fieldName = event.getSource().get('v.value');

		helper.clearFilter(component, fieldName);
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