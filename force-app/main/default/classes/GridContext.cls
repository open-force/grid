/**
 * DTO class that is used to represent the current state of a Grid component instance.
 */
public with sharing class GridContext {

	public String searchTerm;

	public Integer currentPage;
	public Integer pageSize;

	public String sortedBy;
	public String sortedDirection;

	public Map<String, String> activeFilters;
	public Map<String, String> hiddenFilters;
	public Map<String, List<FilterOption>> filterOptions;

	public Integer totalFilteredRecords;
	public Integer totalRecords;

	public GridContext() {
		initialize();
	}

	public void initialize() {

		if(searchTerm == null)
			searchTerm = '';

		if(currentPage == null)
			currentPage = 1;

		if(pageSize == null)
			pageSize = 50;

		if(sortedBy == null)
			sortedBy = '';

		if(sortedDirection == null)
			sortedDirection = '';

		if(activeFilters == null)
			activeFilters = new Map<String, String>();

		if(hiddenFilters == null)
			hiddenFilters = new Map<String, String>();

		if(filterOptions == null)
			filterOptions = new Map<String, List<FilterOption>>();
	}

	public class FilterOption implements Comparable {

		public String value;
		public String label;
		public Boolean checked;

		public FilterOption(String value, String label, Boolean checked) {
			this.value = value;
			this.label = label;
			this.checked = checked;
		}

		public FilterOption(String value, String label) {
			this(value, label, false);
		}

		public Integer compareTo(Object o) {
			FilterOption other = (FilterOption)o;
			if(label == null) {
				if(other.label == null)
					return 0;
				else
					return 1;
			}
			else {
				return label.compareTo(other.label);
			}
		}
	}
}