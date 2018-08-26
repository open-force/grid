({
	/**
	 * Create and fill values for v.simplifiedColumns and v.generatedRowMarkup.
	 */
	populateGeneratedAttributes : function(component) {

		// build stripped down column representations for use in headers
		let simplifiedColumns = [];
		component.get('v.columns').forEach(function(column) {
			let simplified = {}, extracted = JSON.parse(JSON.stringify(column.attributes.values));
			for(let property in extracted) {
				if(property !== 'body')
					simplified[property] = extracted[property].value;
			}
			simplifiedColumns.push(simplified);
		});
		component.set('v.simplifiedColumns', simplifiedColumns);

		// build row template
		component.set('v.generatedRowMarkup', this.buildRowMarkup(component));
	},

	/**
	 * Given a collection of filterOptions, find the matching headers and create lightning:buttonMenu instances on them.
	 *
	 * Because we can't dynamically instantiate lightning:menuItem instances by themselves, we have to rebuild the menu itself
	 * whenever the items change.
	 *
	 * @param component
	 * @param replaceExisting A boolean for whether we should be overwriting an existing menu or adding a new menu
	 */
	buildFilterMenus : function(component, replaceExisting) {

		let filterOptions = component.get('v.context').filterOptions;

		/*
		 * Create representations of each lightning:buttonMenu that we would like to instantiate
		 */
		let menusToCreate = [];

		// for each column we need to filter
		for(let fieldName in filterOptions) {
			if(filterOptions.hasOwnProperty(fieldName)) {

				let filterData = filterOptions[fieldName],
					children = [{
						attributes : {
							values : {
								checked : false,
								label : '-- All --',
								value : '--all--'
							}
						},
						componentDef : 'markup://lightning:menuItem'
					}];

				// for each possible filter choice on this column, create a child that represents a lightning:menuItem
				filterData.forEach(function(choice) {

					// this JSON structure is very specific and represents a ComponentDefRef to the Aura framework
					children.push({
						attributes : {
							values : {
								checked : choice.checked,
								label : choice.label,
								value : choice.value
							}
						},
						componentDef : 'markup://lightning:menuItem'
					});
				});

				// now that we have all the children, add this menu to our list of dynamic components to build
				menusToCreate.push(['lightning:buttonMenu', {
					'aura:id' : fieldName,
					'onselect' : component.getReference('c.filterChosen'),
					'body' : children
				}]);
			}
		}

		/*
		 * Now we ask the framework to dynamically instantiate our buttonMenu components and their children
		 */
		$A.createComponents(menusToCreate, function(components, status) {
			if(status === 'SUCCESS') {
				// for each column we need to filter
				for(let fieldName in filterOptions) {
					if(filterOptions.hasOwnProperty(fieldName)) {

						// pop this menu off the list
						let menu = components.shift();

						/*
						 * We find the header to attach the menu to by using a find() on 'gridHeader', which is
						 * an aura:id we attached to all our header <th> tags. Then we inspect each header to
						 * find the one that matches this menu by looking at its data-fieldname attribute.
						 */
						let matchingHeader = null;
						component.find('gridHeader').forEach(function(header) {
							if(fieldName === header.getElement().getAttribute('data-fieldname')) {
								matchingHeader = header;
							}
						});

						// finally, put this menu on the header
						let headerBody = matchingHeader.get('v.body');
						if(replaceExisting) // if flag is set, overwrite the old menu
							headerBody.splice(-1, 1, menu);
						else // otherwise add to the header body
							headerBody.push(menu);
						matchingHeader.set('v.body', headerBody);
					}
				}

			}
		});
	},

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

	fetchRecords : function(component, onSuccess) {

		let action = component.get('c.serverGetData');
		action.setParams({
			gridDataNamespace : component.get('v.namespace'),
			gridDataClassName : component.get('v.className')
		});
		let context = component.get('v.context');
		if(context)
			action.setParam('serializedGridContext', JSON.stringify(context));
		action.setCallback(this, function(serverResponse) {

			let state = serverResponse.getState();
			if(state === 'SUCCESS') {

				let response = JSON.parse(serverResponse.getReturnValue());

				component.set('v.records', response.records);
				component.set('v.context', response.context);

				console.log('response', response);

				onSuccess();
			}
		});

		$A.enqueueAction(action);
	}
});