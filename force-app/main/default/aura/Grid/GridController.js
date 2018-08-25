({
	doInit : function(component, event, helper) {

		// build stripped down column representations for use in headers
		let simplifiedColumns = [];
		component.get('v.columns').forEach(function(column) {
			let simplified = JSON.parse(JSON.stringify(column.attributes.values));
			delete simplified.body;
			simplifiedColumns.push(simplified);
		});
		component.set('v.simplifiedColumns', simplifiedColumns);

		// build row template
		component.set('v.generatedRowMarkup', helper.buildRowMarkup(component));

		helper.fetchRecords(component);
	}
});