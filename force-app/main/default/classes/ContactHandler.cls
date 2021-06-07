public with sharing class ContactHandler {
    
    /* addContactAccess method:
        accept list of contacts, get map of contact Ids by User Id
        grant Edit permission to user for corresponding contacts
    */
    public static void addContactAccess(List<Contact> contacts) {
        List<Reference__c> references = [select Account__r.Id,Account__r.Territory__c, Contact__r.Id from Reference__c where Contact__r.Id in :contacts];
        List<Account> accounts = new List<Account>();
        for(Reference__c ref : references) { accounts.add(ref.Account__r); }

        Map<Id,Set<Territory__c>> territoriesByAccountId = TerritoryBasedSharing.getTerritoriesByAccount(accounts);
        Map<Id,Set<Id>> accountsByUserId = TerritoryBasedSharing.getAccountsByUserId(territoriesByAccountId);
        Map<Id,Set<Id>> contactsByUserId = TerritoryBasedSharing.getContactsByUserId(accountsByUserId, references);

        for (Id userId : contactsByUserId.keyset()) {
            enableContactSharing(userId, contactsByUserId.get(userId));
        }
    }

    /* removeContactAccess method:
        accept list of contacts, remove manual shares for them
    */
    public static void removeContactAccess(List<Contact> contacts) {
        List<ContactShare> contactShares = [select Id from ContactShare where ContactId in :contacts and RowCause = 'Manual'];
        if(contactShares.size() > 0) {
            delete contactShares;
        }
    }

    /* enableContactSharing method:
        Accept userID and list of contact IDs
        grants Edit permission to user for corresponding contacts
    */
    @future
    public static void enableContactSharing(Id userId, Set<Id> contactIds) {
        List<ContactShare> contactsToShare = new List<ContactShare>();
        for (Id contactId : contactIds) {
            ContactShare contShare = new ContactShare(
                ContactId = contactId,
                UserOrGroupId = userId,
                ContactAccessLevel = 'Edit',
                RowCause = 'Manual'
            );
            contactsToShare.add(contShare);
        }
        if(contactsToShare.size() > 0) {
            insert contactsToShare;
        }
    }
}