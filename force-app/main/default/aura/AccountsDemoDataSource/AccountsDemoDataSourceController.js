({
    fetchRecords : function(component, event) {
        var params = event.getParam('arguments');
        let action = component.get('c.serverGetData');
        let context = params.context;
		if(context)
			action.setParam('serializedGridContext', JSON.stringify(context));
		action.setCallback(this, function(serverResponse) {
            
            let state = serverResponse.getState();
            let response = JSON.parse(serverResponse.getReturnValue());
            params.callback(response, state);
		});

		$A.enqueueAction(action);
	}
})
