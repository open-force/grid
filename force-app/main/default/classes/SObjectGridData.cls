/**
 * Abstract class we can use as a starting point for building data services for Grid component instances
 * where the backing data is some kind of SObject (which could also include external objects or cMDTS).
 */
public with sharing abstract class SObjectGridData implements GridData {

	/**
	 * Get a page of data records, given a specific context.
	 *
	 * @param context Information specifying the records to return (page size, filters, etc)
	 *
	 * @return
	 */
	public List<Object> getRecords(GridContext context) {

		Integer offset = context.pageSize * (context.currentPage - 1);

		/*
		 * Evaluate the active filters and construct SOQL where clauses for each
		 */
		List<String> whereClauses = new List<String>();
		if(context.activeFilters != null && !context.activeFilters.isEmpty()) {

			for(String key : context.activeFilters.keySet()) {

				String newClause = buildFilterClause(key, context.activeFilters.get(key));
				if(String.isNotBlank(newClause))
					whereClauses.add(newClause);
			}
		}
		String staticFilterClause = getStaticFilterClause(), staticWhereStr = '';
		if(String.isNotBlank(staticFilterClause)) {
			whereClauses.add(staticFilterClause);
			staticWhereStr = ' WHERE ' + staticFilterClause;
		}

		/*
		 * Check for a search term, and build appropriate where clauses if one is present.
		 */
		if(String.isNotBlank(context.searchTerm)) {
			List<String> searchClauses = new List<String>();

			for(String columnName : getSearchableColumnNames()) {

				String newClause = buildSearchClause(columnName, context.searchTerm);
				if(String.isNotBlank(newClause))
					searchClauses.add(newClause);
			}

			// join our search clauses with OR and add them as a single where clause
			if(searchClauses.size() > 0)
				whereClauses.add('(' + String.join(searchClauses, ' OR ') + ')');
		}

		String whereStr = !whereClauses.isEmpty() ? ' WHERE ' + String.join(whereClauses, ' AND ') : '';

		/*
		 * Construct an ORDER BY clause if we are doing sorting
		 */
		String orderByStr = '';
		if(String.isNotEmpty(context.sortedBy))
			orderByStr = columnNameToDatabaseField(context.sortedBy) + ' ' + ('asc'.equalsIgnoreCase(context.sortedDirection) ? 'ASC NULLS FIRST' : 'DESC NULLS LAST') + ',';

		/*
		 * Actually query the database for records using the clauses we built
		 */
		String query = 'SELECT ' + String.join(new List<String>(getSelectFields()), ',') +
			' FROM ' + getObjectName() +
			whereStr +
			' ORDER BY ' + orderByStr + ' ' + getDefaultOrderByClause() +
			' LIMIT ' + context.pageSize +
			' OFFSET ' + offset;

		// get the records for this page
		List<Object> records = new List<Object>();
		for(SObject o : Database.query(query)) {
			records.add(transform(o));
		}

		/*
		 * Do some counting.
		 */
		context.totalRecords = Database.countQuery('SELECT COUNT() FROM ' + getObjectName() + staticWhereStr);
		if(String.isNotEmpty(whereStr))
			context.totalFilteredRecords = Database.countQuery('SELECT COUNT() FROM ' + getObjectName() + ' ' + whereStr);
		else
			context.totalFilteredRecords = context.totalRecords;

		/*
		 * Figure out what filter choices should be offered for each column that is declared filterable
		 */
		context.filterOptions = getFilterOptions(context.activeFilters, whereStr);

		return records;
	}

	/**
	 * Allows children to create their own implementation for building FilterOptions to use in the column header dropdowns. For most
	 * SObjects the default implementation (counting by possible value) will be perfectly fine.
	 *
	 * @param activeFilters Any currently-active filters (fieldName => filterValue)
	 * @param whereStr The current WHERE clause we are using to filter our records
	 *
	 * @return
	 */
	virtual protected Map<String, List<GridContext.FilterOption>> getFilterOptions(Map<String, String> activeFilters, String whereStr) {

		Map<String, List<GridContext.FilterOption>> filterOptions = new Map<String, List<GridContext.FilterOption>>();

		for(String columnName : getFilterableColumnNames()) {

			String fieldName = columnNameToDatabaseField(columnName);
			List<GridContext.FilterOption> options = new List<GridContext.FilterOption>();

			for(AggregateResult res : Database.query('SELECT COUNT(Id) numRecords, ' + fieldName + ' FROM ' + getObjectName() + ' ' + whereStr + ' GROUP BY ' + fieldName)) {
				String fieldValue = String.valueOf(res.get(fieldName));
				options.add(getFilterOption(columnName, fieldValue, activeFilters.get(columnName), (Integer)res.get('numRecords')));
			}
			options.sort();

			filterOptions.put(columnName, options);
		}

		return filterOptions;
	}

	/**
	 * Given a frontend column name and a filter value, build the appropriate SOQL clause to filter this database field.
	 *
	 * @param column
	 * @param value
	 *
	 * @return
	 */
	virtual protected String buildFilterClause(String column, String value) {
		return columnNameToDatabaseField(column) + ' = \'' + String.escapeSingleQuotes(value) + '\'';
	}

	/**
	 * Given a frontend column name and a search term, build the appropriate SOQL clause to search for this term in this column.
	 *
	 * @param column
	 * @param searchTerm
	 *
	 * @return
	 */
	virtual protected String buildSearchClause(String column, String searchTerm) {
		return columnNameToDatabaseField(column) + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
	}

	/**
	 * In case there is some filtering that should always be applied to your table, you can set that filter here.
	 *
	 * @return A valid SOQL filter clause that will always be applied, for example: return 'Active__c = true';
	 */
	virtual protected String getStaticFilterClause() {
		return '';
	}

	/**
	 * Helps us map frontend column names to actual database field names, so we can build queries.
	 *
	 * @param columnName
	 *
	 * @return
	 */
	virtual protected String columnNameToDatabaseField(String columnName) {
		return columnName;
	}

	/**
	 * List out any fields you want retrieved from the database for each record.
	 *
	 * @return
	 */
	abstract protected Set<String> getSelectFields();

	/**
	 * The Salesforce object to query records from.
	 *
	 * @return
	 */
	abstract protected String getObjectName();

	/**
	 * A default ORDER BY clause (just field name and ASC/DESC)
	 *
	 * @return
	 */
	abstract String getDefaultOrderByClause();

	/**
	 * Do any necessarily transformations on the record before it is handed to the frontend.
	 *
	 * @param record
	 *
	 * @return
	 */
	virtual protected Object transform(SObject record) {
		return record;
	}

	/**
	 * List of the columns that can have filters applied.
	 *
	 * @return
	 */
	virtual protected List<String> getSearchableColumnNames() {
		return new List<String>();
	}

	/**
	 * List of the columns that can have filters applied.
	 *
	 * @return
	 */
	virtual protected List<String> getFilterableColumnNames() {
		return new List<String>();
	}

	/**
	 * Describe the possible filter choices.
	 *
	 * @return
	 */
	abstract protected GridContext.FilterOption getFilterOption(String columnName, String columnValue, String currentSelection, Integer count);
}