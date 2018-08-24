({
	doInit : function(component, event, helper) {

		// build records
		let records = [];
		for(let i = 10000; i < 10500; i++){
			records.push({'id': i, name:"Record "+i});
		}
		component.set('v.records', records);

		// build stripped down column representations for use in headers
		let simplifiedColumns = [];
		component.get('v.columns').forEach(function(column){
			let simplified = JSON.parse(JSON.stringify(column.attributes.values));
			delete simplified.body;
			simplifiedColumns.push(simplified);
		});
		component.set('v.simplifiedColumns', simplifiedColumns);

		// build row template
		component.set('v.generatedRowMarkup', helper.buildRowMarkup(component));
	}
});