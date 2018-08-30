/**
 * Abstract class we can use as a starting point for building data services for Grid component instances
 * where the backing data is some kind of custom metadata type, which have some odd restrictions.
 */
public with sharing abstract class CustomMetadataGridData extends SObjectGridData {

	/**
	 * We override the SObject version of this method because OR clauses are not supported in cMDTs.
	 *
	 * This means that if the user wants to do a search, our normal implementation will throw an error.
	 *
	 * @param context Information specifying the records to return (page size, filters, etc)
	 *
	 * @return
	 */
	public override List<Object> getRecords(GridContext context) {

		Integer offset = context.pageSize * (context.currentPage - 1);

		// if we don't need to search, just bail out and do the usual implementation
		if(String.isBlank(context.searchTerm)) {
			return super.getRecords(context);
		}

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

		String whereStr = !whereClauses.isEmpty() ? ' WHERE ' + String.join(whereClauses, ' AND ') : '';

		/*
		 * Construct an ORDER BY clause if we are doing sorting
		 */
		String orderByStr = '';
		if(String.isNotEmpty(context.sortedBy))
			orderByStr = columnNameToDatabaseField(context.sortedBy) + ' ' + ('asc'.equalsIgnoreCase(context.sortedDirection) ? 'ASC NULLS FIRST' : 'DESC NULLS LAST') + ',';

		/*
		 * Actually query the database for records using the clauses we built. For our custom implementation
		 * we are going to live dangerously and remove the limit and offset keywords and retrieve every single
		 * cMDT record that matches our filter criteria (not including search, which we will do manually).
		 */
		String query = 'SELECT ' + String.join(new List<String>(getSelectFields()), ',') +
			' FROM ' + getObjectName() +
			whereStr +
			' ORDER BY ' + orderByStr + ' ' + getDefaultOrderByClause();

		// get the records for this page
		List<Object> records = new List<Object>();
		for(SObject o : Database.query(query)) {

			System.debug(LoggingLevel.WARN, o.getPopulatedFieldsAsMap());

			/*
			 * Apply search criteria and accept/reject each record
			 */
			Boolean matchesSearch = false; // does the current record match our search term?
			for(String columnName : getSearchableColumnNames()) {

				String fieldName = columnNameToDatabaseField(columnName);
				String fieldValue = String.valueOf(extractValue(o, fieldName)); // assume all searchable fields can be strings

				System.debug(LoggingLevel.WARN, fieldName + '[' + columnName + '] => ' + fieldValue);

				// if this field's database value contains our search term, mark this record as a match on search
				if(fieldValue != null && fieldValue.containsIgnoreCase(context.searchTerm)) {
					matchesSearch = true;
					break;
				}
			}

			// only include a record in our result if it matches our search
			if(matchesSearch)
				records.add(transform(o));
		}

		/*
		 * Do some counting.
		 */
		context.totalRecords = Database.countQuery('SELECT COUNT() FROM ' + getObjectName() + staticWhereStr);
		context.totalFilteredRecords = records.size();

		/*
		 * Manually apply our "limit" and "offset" by iterating over a slice of our records list.
		 */
		List<Object> paginatedRecords = new List<Object>();
		for(Integer i = offset; i < offset + context.pageSize; i++) {

			if(i >= records.size()) // bail out early if we run out of records before we hit our page size
				break;

			paginatedRecords.add(records[i]);
		}

		/*
		 * Figure out what filter choices should be offered for each column that is declared filterable
		 */
		context.filterOptions = getFilterOptions(context.activeFilters, whereStr);

		return paginatedRecords;
	}

	/**
	 * We have to have our own implementation because cMDTs don't support COUNT(Id) + GROUP BY. We will likely not have
	 * tooooo many cMDTs in an org so we're just going to query and count them all. Inefficient but it'll get us what we need.
	 */
	public override Map<String, List<GridContext.FilterOption>> getFilterOptions(Map<String, String> activeFilters, String whereStr) {

		Map<String, List<GridContext.FilterOption>> filterOptions = new Map<String, List<GridContext.FilterOption>>();
		List<String> queryFields = new List<String>();
		Map<String, Map<Object, Integer>> countsByValueByField = new Map<String, Map<Object, Integer>>();

		// translate our column list into database field names
		for(String columnName : getFilterableColumnNames()) {
			String fieldName = columnNameToDatabaseField(columnName);
			queryFields.add(fieldName);
			countsByValueByField.put(fieldName, new Map<Object, Integer>());
		}

		// get every Link out and build a big data structure counting all the occurrences of unique field values for fields in our list
		String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM ' + getObjectName() + ' ' + whereStr;
		for(SObject record : Database.query(query)) {
			for(String fieldName : queryFields) {

				Map<Object, Integer> countsByValue = countsByValueByField.get(fieldName);
				Object value = extractValue(record, fieldName);

				if(countsByValue.containsKey(value)) {
					countsByValue.put(value, countsByValue.get(value) + 1);
				}
				else {
					countsByValue.put(value, 1);
				}
			}
		}

		// finally, turn our count collection into a collection of FilterOptions
		for(String columnName : getFilterableColumnNames()) {

			List<GridContext.FilterOption> options = new List<GridContext.FilterOption>();
			Map<Object, Integer> countsByValue = countsByValueByField.get(columnNameToDatabaseField(columnName));
			for(Object value : countsByValue.keySet()) {
				options.add(getFilterOption(columnName, String.valueOf(value), activeFilters.get(columnName), countsByValue.get(value)));
			}
			options.sort();

			filterOptions.put(columnName, options);
		}

		return filterOptions;
	}

	/**
	 * Helper method that can recursively dig into a nested SObject in case we queried on relationship fields.
	 *
	 * @param record
	 * @param fieldName
	 *
	 * @return
	 */
	private Object extractValue(SObject record, String fieldName) {

		if(fieldName.contains('.')) {
			List<String> keyParts = fieldName.split('\\.', 2);
			return extractValue(record.getSObject(keyParts[0]), keyParts[1]);
		}
		else {
			return record.get(fieldName);
		}
	}
}