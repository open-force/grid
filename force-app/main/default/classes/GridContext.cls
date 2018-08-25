/**
 * DTO class that is used to represent the current state of a Grid component instance.
 */
public with sharing class GridContext {

	public Integer currentPage;
	public Integer pageSize;

	public Integer totalFilteredRecords;
	public Integer totalRecords;
}