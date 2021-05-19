Account dummy = new Account(Name = 'Dummy account for contacts');
insert dummy;

List<Account> all_accounts = [select Name,Territory__r.Id from Account];


List<Territory__c> territories = [select Id,Name from Territory__c];
List<Account> newAccounts = new List<Account>();
for(Territory__c terr: territories) {
    newAccounts.add(new Account(Name = 'Account1 ' + terr.Name, Territory__c = terr.Id));
    newAccounts.add(new Account(Name = 'Account2 ' + terr.Name, Territory__c = terr.Id));
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
AccountShare acctShr = new AccountShare();
acctShr.AccountId = acct.Id;
acctShr.UserOrGroupId = salesRep.Id;
acctShr.AccountAccessLevel = 'Edit';
acctShr.ContactAccessLevel = 'Read';
acctShr.OpportunityAccessLevel = 'Read';
acctShr.CaseAccessLevel = 'Read';
Database.SaveResult dsr = Database.insert(acctShr,false);
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