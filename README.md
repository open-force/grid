# open-force Grid component

A Lightning Component grid implementation that expects a server-side data store.

## Setting up the demo ##

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