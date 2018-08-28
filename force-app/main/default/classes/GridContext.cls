/**
 * DTO class that is used to represent the current state of a Grid component instance.
 */
public with sharing class GridContext {

	public String searchTerm = '';

	public Integer currentPage = 1;
	public Integer pageSize = 50;

	public String sortedBy = '';
	public String sortedDirection = '';

	public Map<String, String> activeFilters = new Map<String, String>();
	public Map<String, List<FilterOption>> filterOptions = new Map<String, List<FilterOption>>();

	public Integer totalFilteredRecords;
	public Integer totalRecords;

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