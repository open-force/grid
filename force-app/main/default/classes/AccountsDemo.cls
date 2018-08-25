/**
 * Example data provider for the Grid component.
 */
public with sharing class AccountsDemo implements GridData {

	public List<Object> getRecords(GridContext context) {

		return [SELECT Name, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, AccountNumber, Industry, AnnualRevenue, NumberOfEmployees, Description, Id, LastModifiedDate, CreatedDate, AccountSource FROM Account];
	}
}