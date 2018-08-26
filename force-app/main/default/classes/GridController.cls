/**
 * Server-side handler for the Grid component.
 */
public with sharing class GridController {

	/**
	 * Fetch paginated data from the server.
	 *
	 * @param serializedGridContext Serialized representation of current state of the grid, such as active filters and page number.
	 *
	 * @return A serialized response with data records and updated grid context
	 */
	@AuraEnabled
	public static String serverGetData(String gridDataNamespace, String gridDataClassName, String serializedGridContext) {

		// get an instance of GridData to work with
		GridData data = (GridData)Type.forName(gridDataNamespace, gridDataClassName).newInstance();

		// get the current GridContext for the active Grid instance
		System.debug(LoggingLevel.WARN, serializedGridContext + ', [' + String.isBlank(serializedGridContext) + ']');
		GridContext context = String.isBlank(serializedGridContext) ? new GridContext() : (GridContext)JSON.deserialize(serializedGridContext, GridContext.class);

		Map<String, Object> response = new Map<String, Object>();
		response.put('records', data.getRecords(context));
		response.put('context', context);

		return JSON.serialize(response);
	}
}