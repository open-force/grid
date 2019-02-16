# open-force Grid component

A Lightning Component grid implementation that is meant to jumpstart your development of a custom grid. 

This implementation is biased towards a scenario where you have some large number of records in your database and you need a table to surface some of those records at a time. You expect search, filtering, sorting, paginating all to work not just in the browser but to also consider the other records back in the database.

### What this component has ###
* Driven by a data store
	* Frontend data source: serve data from Javascript
	* Backend data source: serve data from Apex (can be standard objects, custom objects, cMDTs, external objects...anything Apex can touch)
* Pagination
* Search
* Filtering
* Sorting

### Design philosophy ###

This grid component implementation is intentionally more hands-on than something like lightning:datatable or other implementations we've seen. 

It does not assume your record shape in the database is exactly the same shape you are going to surface in your UI. It does not assume what the markup for each column is going to be based on the database field type. You are in the driver seat.

Consequently, this is a more verbose implementation and is not a good fit if you don't need the additional level of access and customization.

## Example Code ##

Our desire was to build a table that would support arbitrary column markup in a syntax that would be intuitive for developers. Especially important for us was combining column definitions with row cell markup in the same syntax.

Here is the sample markup from the built-in "Accounts Demo" table:

```xml
<aura:component implements="force:appHostable" description="An example of how you can use the Grid component to fetch and filter/sort/page server data.">

	<!--Content-->
	<lightning:card title="Accounts Demo" class="slds-m-bottom_medium slds-p-horizontal_small">
		<p>This is an example of how to use the Grid component. Below you will see Accounts in this org.</p>
		<p>To see the code involved, look at the Lightning component AccountsDemo.cmp and its corresponding Apex support class AccountsDemo.cls.</p>
	</lightning:card>

	<c:Grid>

		<aura:set attribute="startingFilters">
			<c:GridFilter fieldName="Type" value="Channel Partner / Reseller" />
		</aura:set>

		<aura:set attribute="dataSource">
			<c:ApexDataSource className="AccountsDemo" />
		</aura:set>

		<c:Column fieldName="Id" label="Account Id">
			{#record.Id}
		</c:Column>

		<c:Column fieldName="AccountNumber" label="Account Number" sortable="true">
			{#record.AccountNumber}
		</c:Column>

		<c:Column fieldName="Name" label="Account Name" sortable="true">
			{#record.Name}
		</c:Column>

		<c:Column fieldName="Type" label="Account Type" sortable="true">
			{#record.Type}
		</c:Column>

		<c:Column fieldName="NumberOfEmployees" label="Employees" sortable="true">
			<lightning:formattedNumber value="{#record.NumberOfEmployees}" />
		</c:Column>

		<c:Column fieldName="AnnualRevenue" label="Annual Revenue" sortable="true">
			<lightning:formattedNumber value="{#record.AnnualRevenue}" style="currency" />
		</c:Column>

		<c:Column fieldName="Industry" label="Industry" sortable="true">
			{#record.Industry}
		</c:Column>

	</c:Grid>

</aura:component>
```

### Accounts Demo Screenshots ###

![You can search, sort, filter, and page through the records in your data store](/data/accounts_demo.png)

![You can see how many records would be available when considering filters](/data/filter_dropdown.png)

## Additional Filtering ##

In addition to the built-in filtering that a user can do, you are able to do two additional things in your markup as you set up a Grid component.

### Starting Filters ###

A "starting" filter looks like a normal filter a User would have selected, but it is already in place when the Grid is rendered for the first time. Use this when the user is arriving at the Grid with some initial state already in place. Perhaps you show them a list of choices somewhere, and clicking a choice brings them the Grid, already pre-filtered for that choice.

You can define zero or more filters for the `startingFilters` attribute.

**Syntax:**
```xml
<c:Grid>

	<aura:set attribute="startingFilters">
		<c:GridFilter fieldName="Type" value="Channel Partner / Reseller" />
	</aura:set>
```

The `fieldName` attribute should match one of your `c:Column` definitions.

### Hidden Filters ###

Hidden filters are set up pretty much identically to starting filters, except:

* They are not visible to the user
* They cannot be canceled by the user

Use these when you want to add a filter to the Grid that you know you're going to want in place. This saves you the trouble of having to write a new data provider to exclude whatever you are filtering.

You can define zero or more filters for the `hiddenFilters` attribute.

**Syntax:**
```xml
<c:Grid>

	<aura:set attribute="hiddenFilters">
		<c:GridFilter fieldName="Type" value="Channel Partner / Reseller" />
	</aura:set>
```

## Getting Data / Setting up a Data Source ##

Data is served to the Grid by your specified "data source":

```xml
<c:Grid>

	<aura:set attribute="dataSource">
		<c:ApexDataSource className="AccountsDemo" />
	</aura:set>
```

A data source is any Aura component that implements the `c:GridDataSource` interface:

**[c:GridDataSource](force-app/main/default/aura/GridDataSource/GridDataSource.intf) interface:**
```xml
<aura:interface description="Implement this interface to be usable as a data provider for the Grid component">
	<aura:method name="fetchRecords">
		<aura:attribute name="context" type="Map" />
		<aura:attribute name="callback" type="Function" />
	</aura:method>
</aura:interface>
```

Grid doesn't care where you get data. It just cares that you implement this single function, and that you know how to interpret the [context object](force-app/main/default/classes/GridContext.cls) that is passed to this function.

If you want to handle data provisioning entirely in Javascript, go right ahead. If you'd like to have the data come from the server, we've included some prebuilt elements to help you do that.

### Built-in Apex Data Source ###

Included in this repository is a data provider that knows how to talk to Apex to fetch data. Supporting classes exist on the backend to make this really easy.

The provided [ApexDataSource](force-app/main/default/aura/ApexDataSource) Aura component talks to the [GridController](force-app/main/default/classes/GridController.cls) Apex class.

**GridController** expects to instantiate some class you've built that implements the [GridData](force-app/main/default/classes/GridData.cls) Apex interface.

We've already written two implementations of **GridData**. Extend whichever you like:

* [SObjectGridData](force-app/main/default/classes/SObjectGridData.cls) - knows how to work with SObjects
* [CustomMetadataGridData](force-app/main/default/classes/CustomMetadataGridData.cls) - knows how to work with cMDT records

To use the built-in **ApexDataSource** data provider, simply pass it the namespace and className of your implementation of **GridData**. Here's that sample code again:

```xml
<c:Grid>

	<aura:set attribute="dataSource">
		<c:ApexDataSource className="AccountsDemo" />
	</aura:set>
```

To understand how setting `className` = "AccountsDemo" is going to get you data, just have a look at [AccountsDemo](force-app/main/default/classes/AccountsDemo.cls).

## Running the demo ##

This component is available as a self-contained SFDX project. If you would like to run the example implementation, clone the repository then set up a new scratch org by running:

    sfdx force:org:create -f config/project-scratch-def.json -a grid
    
This builds a scratch org named "grid". Now run:

    sfdx force:source:push -u grid
    
This pushes the project into that new scratch org. Next run:

    sfdx force:data:bulk:upsert -s Account -f data/FakeSalesforceAccounts.csv -i Id -u grid
    
This pushes some fake Account rows into the new org that will be used by the demo.

Finally, run:

    sfdx force:org:open -u grid -p /lightning/n/Accounts_Demo
    
This will open your new scratch org in a browser window.

## Caveats ##

This component is not hardened for security. For example, the example AccountsDemo apex controller will happily violate FLS and CRUD permissions to retrieve fields to display.

If you use this component, think through the specific security requirements for your implementation carefully.