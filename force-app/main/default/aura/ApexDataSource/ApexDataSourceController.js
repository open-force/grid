({
	fetchRecords : function(component, event) {

		let params = event.getParam('arguments'), action = component.get('c.serverGetData'), context = params.context;

		action.setParam('gridDataNamespace', component.get('v.namespace'));
		action.setParam('gridDataClassName', component.get('v.className'));
		if(context)
			action.setParam('serializedGridContext', JSON.stringify(context));

		action.setCallback(this, function(serverResponse) {

			let state = serverResponse.getState();
			let response = JSON.parse(serverResponse.getReturnValue());
			params.callback(response, state);
		});

		$A.enqueueAction(action);
	}
});