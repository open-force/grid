public with sharing class AccountsDemoController {
    @AuraEnabled
	public static String serverGetData(String serializedGridContext) {

		// get an instance of GridData to work with
		AccountsDemo data = new AccountsDemo();

		// get the current GridContext for the active Grid instance
		GridContext context = String.isBlank(serializedGridContext) ? new GridContext() : (GridContext)JSON.deserialize(serializedGridContext, GridContext.class);
		context.initialize(); // fill in any blank required fields with sensible defaults

		Map<String, Object> response = new Map<String, Object>();
		response.put('records', data.getRecords(context));
		response.put('context', context);

		return JSON.serialize(response);
	}
}
