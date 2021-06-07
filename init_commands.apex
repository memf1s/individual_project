List<Account> accounts = [select Id,Name,Territory__c (select Id,LastMame from Contacts) from Account];
Map<Account,List<Contact>> contactsByAccount = new Map<Account,List<Contact>>([select Id,Name,Territory__c, (select Id,Name from Contacts) from Account]);
System.debug(contactsByAccount);

TerritoryBasedSharing.mytestMethod();

List<Account> accts = [select Id,Name from Account where Name like 'Account1%'];
List<Reference__c> contacts = [select Contact__r.Id,Contact__r.Name from Reference__c where Account__r.Id in :accts];
System.debug(contacts);
system.debug('SINGLE CONTACT ID : ' +contacts[0].Contact__r.Id);
system.debug('SINGLE CONTACT ID2 : ' +contacts[0].Contact__c);


List<Account> accts = [select Id,Name from Account where Name like 'Account1%'];
List<Contact> contacts = [select Id,Name from Contact where References1__r.Account__r.Id in :accts];
System.debug(contacts);


// Get a map of all fields available to you on the MyObject__c table/object
// keyed by the API name of each field
Map<String,Schema.SObjectField> myObjectFields 
   = TerritoryUser__c.SObjectType.getDescribe().fields.getMap();


Schema.DescribeSObjectResult R = Territory__c.SObjectType.getDescribe();
List<Schema.ChildRelationship> C = R.getChildRelationships(); 
System.debug(JSON.serializePretty(C));

// Get a Set of the field names
Set<String> myObjectFieldAPINames = myObjectFields.keyset();
// Print out the names to the debug log
 String allFields = 'ALL ACCESSIBLE FIELDS on MyObject__c:\n\n';
for (String s : myObjectFieldAPINames) {
    allFields += s + '\n';
}
System.debug(allFields);

select Id,Name from User where ID = '00509000006SUMMAA4'

Account dummy = new Account(Name = 'Dummy account for contacts');
insert dummy;

List<Account> all_accounts = [select Name,Territory__r.Id from Account];

select Id,Name,Parent_Territory__c from Territory__c

List<Territory__c> territories = [select Id,Name from Territory__c];
List<Account> newAccounts = new List<Account>();
for(Territory__c terr: territories) {
    newAccounts.add(new Account(Name = 'Account21222r ' + terr.Name, Territory__c = terr.Id));
    newAccounts.add(new Account(Name = 'Account22333r ' + terr.Name, Territory__c = terr.Id));
}
insert newAccounts;

Account dummy = [select Id,Name from Account where Name like 'dummy%'];
List<Account> accounts = [select Id,Name,Territory__r.Name from Account where Name like 'Account%'];
List<Contact> contacts = new List<Contact>();
List<Reference__c> refs = new List<Reference__c>();
for(Account acc : accounts) {
    List<Contact> contacts = new List<Contact>();
    contacts.add( new Contact(LastName = 'Contact1 ' + acc.Territory__r.Name, AccountId = dummy.Id) );
    contacts.add( new Contact(LastName = 'Contact2 ' + acc.Territory__r.Name, AccountId = dummy.Id) );
    insert contacts;
    refs.add(new Reference__c(Account__c = acc.Id,Contact__c = contacts[0].Id));
    refs.add(new Reference__c(Account__c = acc.Id,Contact__c = contacts[1].Id));
}
insert refs;


Account acct = [select Id,Name from Account where Name like 'Account1 Bemowo'];
User salesRep = [select Id,Name,Username from User where Username = 'jdoe_salesrep@test.com'];
AccountShare accShr = new AccountShare(
    AccountId = acct.Id,
    UserOrGroupId = salesRep.Id,
    AccountAccessLevel = 'Edit',
    ContactAccessLevel = 'Read',
    OpportunityAccessLevel = 'Read',
    CaseAccessLevel = 'Read'
);
Database.SaveResult dsr = Database.insert(accShr,false);
if (!dsr.isSuccess()) {
    Database.Error err = dsr.getErrors()[0];
    System.debug(err);
} else {
    List<ContactShare> contactShr = new List<ContactShare>();
    List<Reference__c> references = [select Contact__c from Reference__c where Account__c = :acct.Id];
    for (Reference__c ref : references) {
        ContactShare shr = new ContactShare();
        shr.ContactId = ref.Contact__c;
        shr.UserOrGroupId = salesRep.Id;
        shr.ContactAccessLevel = 'Edit';
        contactShr.add(shr);
    }
    List<Database.SaveResult> dsr2 = Database.insert(contactShr,false);
    for (Database.SaveResult sr : dsr2) {
        if (!sr.isSuccess()) {
            Database.Error[] errors = sr.getErrors();
            for (Database.Error err : errors) {
                System.debug(err);
            }
        }
    }
}

List<String> terrNames = new List<String>{'Paris','Warsaw'};
List<Territory__c> topLevels = [select Id,Name from Territory__c where Name like :terrNames];
List<Territory__c> territoriesToUpdate = new List<Territory__c>(topLevels);
List<Territory__c> currentLevel= new List<Territory__c>(topLevels);
Boolean isDone = false;
while(!isDone) {
    currentLevel = [select Id,Name from Territory__c where Parent__c in :currentLevel];
    territoriesToUpdate.addall(currentLevel);
    if (currentLevel.size() == 0) {
        isDone = true;
    }
}
List<Account> accountsToUpdate = [select Id from Account where Territory__c in :territoriesToUpdate];
List<Contact> contacts = [select Id,Name from Contact where Id in (select Contact__c from Reference__c where Account__c in :accountsToUpdate)];
System.debug(contacts);

System.debug(JSON.serializePretty(territoriesToUpdate));
System.debug('account count: ' + accountsToUpdate.size());



SELECT id,AccountId,UserOrGroupId FROM AccountShare

List<TerritoryUser__c> tUsersList = [select Territory__c,User__c from TerritoryUser__c];
List<Account> accountsToUpdate = [select Id from Account];
List<AccountShare> acctShr = [select Id from AccountShare where AccountId in :accountsToUpdate and UserOrGroupId = :tUsersList[0].User__c];
List<Contact> contacts = [select Id,Name from Contact where Id in (select Contact__c from Reference__c where Account__c in :accountsToUpdate)];
List<ContactShare> contactShare = [select Id from ContactShare where ContactId in :contactsToUpdate and UserOrGroupId = :tUsersList[0].User__c];
System.debug(acctShr);
System.debug(contactShare);


List<Account> accountsToUpdate = [select Id, Territory__c from Account where Territory__c in (select Id from Territory__c where Name = 'Poznyaki')];
List<Id> terrIds = new List<Id>();
for(Account acc : accountsToUpdate) { 
        terrIds.add((Id)acc.Territory__c);
}
List<TerritoryUser__c> tUsers = [select User__c,Territory__c from TerritoryUser__c where Territory__c in :terrIds];
System.debug(tUsers);



select TerritoryUsers__r.User__c,TerritoryUsers__r.Territory__c from Territory__c where Accounts__r.Id in :accountsToUpdate

List<Contact> contacts = [select Id,Name from Contact where Id in (select Contact__c from Reference__c where Account__c in :accountsToUpdate)];
System.debug(contacts);



List<TerritoryUser__c> tUserList = [select Id,Territory__c from TerritoryUser__c];
List<Territory__c> topLevels = [select Id,Name from Territory__c where Id in (select Territory__c from TerritoryUser__c where Id in :tUserList)];
System.debug(topLevels);

List<AccountShare> acctShr = [select iD from AccountShare where UserOrGroupId='00509000006SY2gAAG'];
List<ContactShare> contactShr = [select iD from ContactShare where UserOrGroupId='00509000006SY2gAAG'];
Database.delete(acctShr,false);
Database.delete(contactShr,false);


List<String> terrNames = new List<String>{'Paris'};
List<Territory__c> territories = [select Id, Name from Territory__c where Name like :terrNames];
List<Account> accountsToUpdate = [select Id from Account where Territory__c in :territories];
List<Reference__c> contactsToUpdate = [select Contact__c,Contact__r.Name from Reference__c where Account__c in :accountsToUpdate];
System.debug(contactsToUpdate);

SELECT Account.Name, (SELECT Contact.FirstName, Contact.LastName FROM Account.Contacts) FROM Account

    // Get the describe result for the Name field on the Account object
    Schema.DescribeFieldResult dfr = Schema.sObjectType.Account.fields.Name;
     
    // Verify that the field token is the token for the Name field on an Account object
    System.assert(dfr.getSObjectField() == Account.Name);
     
    // Get the describe result from the token
    dfr = dfr.getSObjectField().getDescribe();





SObjectType tUserType = Schema.getGlobalDescribe().get('TerritoryUser__c');
Map<String,Schema.SObjectField> mfields = tUserType.getDescribe().fields.getMap();
for (Schema.SObjectField field : mfields.values()) {
    System.debug(field);
}


        ContactShare shr = new ContactShare();
        shr.ContactId = '0030900000HuynEAAR';
        shr.UserOrGroupId = '00509000006SY2gAAG';
        shr.ContactAccessLevel = 'Edit';
Database.SaveResult dsr2 = Database.insert(shr,false);