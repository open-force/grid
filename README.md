# open-force Grid component

A Lightning Component grid implementation that is meant to jumpstart your development of a custom grid. 

This implementation is biased towards a scenario where you have some large number of records in your database and you need a table to surface some of those records at a time. You expect search, filtering, sorting, paginating all to work not just in the browser but to also consider the other records back in the database.

### What this component has ###
* Driven by a server-side data store (can be standard objects, custom objects, cMDTs, external objects...anything Apex can touch)
* Pagination
* Search
* Filtering
* Sorting

### What this component is not ###
* This component is not designed to work with records that only live in the browser; server-side controller needed!

### Design philosophy ###

This grid component implementation is intentionally more hands-on than something like lightning:datatable or other implementations we've seen. 

It does not assume your record shape in the database is exactly the same shape you are going to surface in your UI. It does not assume what the markup for each column is going to be based on the database field type. You are in the driver seat.

Consequently, this is a more verbose implementation and is not a good fit if you don't need the additional level of access and customization.

## Example Code ##

Our desire was to build a table that would support arbitrary column markup in a syntax that would be intuitive for developers. Especially important for us was combining column definitions with row cell markup in the same syntax.

Here is the sample markup from the built-in "Accounts Demo" table:

```
<aura:component description="An example of how you can use the Grid component to fetch and filter/sort/page server data.">

	<c:Grid className="AccountsDemo">

		<lightning:card title="Accounts Demo" class="slds-m-bottom_medium slds-p-horizontal_small">
			<p>This is an example of how to use the Grid component. Below you will see Accounts in this org.</p>
			<p>To see the code involved, look at the Lightning component AccountsDemo.cmp and its corresponding Apex support class AccountsDemo.cls.</p>
		</lightning:card>

		<aura:set attribute="columns">

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

		</aura:set>

	</c:Grid>

</aura:component>
```

Each Lightning component that invokes this Grid component declares an Apex class that will be used to serve records back to the component.

### Accounts Demo Screenshots ###

![You can search, sort, filter, and page through the records in your data store](/data/accounts_demo.png)

![You can see how many records would be available when considering filters](/data/filter_dropdown.png)

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