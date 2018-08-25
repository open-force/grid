({
	buildRowMarkup : function(component) {

		// set up ComponentDefRef to use for each row
		let rowTemplate = component.get('v.rowTemplate')[0];
		rowTemplate.attributes.values.body = rowTemplate.attributes.values.body || {descriptor : 'body', value : []};
		delete rowTemplate.attributes.valueProvider;

		// set up ComponentDefRef to use for each row cell
		let cellTemplate = component.get('v.cellTemplate')[0];
		cellTemplate.attributes.values.body = cellTemplate.attributes.values.body || {descriptor : 'body', value : []};
		delete cellTemplate.attributes.valueProvider;
		cellTemplate = JSON.stringify(cellTemplate);

		// build cell markup, one cell for each column that we were given
		component.get('v.columns').forEach(function(column) {

			// get a clean object for this cell
			let cellForThisColumn = JSON.parse(cellTemplate);

			// merge column markup into the cell body
			cellForThisColumn.attributes.values.body.value = cellForThisColumn.attributes.values.body.value.concat(column.attributes.values.body.value);

			// add this cell to the row's body
			rowTemplate.attributes.values.body.value.push(cellForThisColumn);
		});

		return rowTemplate;
	},

	fetchRecords : function(component) {

		let action = component.get('c.serverGetData');
		action.setParams({
			gridDataNamespace : component.get('v.namespace'),
			gridDataClassName : component.get('v.className')
		});
		action.setCallback(this, function(serverResponse) {

			let state = serverResponse.getState();
			if(state === 'SUCCESS') {
				let data = JSON.parse(serverResponse.getReturnValue());
				component.set('v.records', data.records);
				console.log('records', data.records);
			}
		});

		$A.enqueueAction(action);
	}
});