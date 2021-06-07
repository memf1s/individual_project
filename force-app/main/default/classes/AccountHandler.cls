public with sharing class AccountHandler {

    /* addAccountAccess method:
        Accept list of accounts, find users with territory permissions
        build map of accounts by user, pass the map to add sharing rules
    */
    public static void addAccountAccess(List<Account> accounts) {
        Map<Id,Set<Territory__c>> territoriesByAccountId = TerritoryBasedSharing.getTerritoriesByAccount(accounts);
        Map<Id,Set<Id>> accountsByUserId = TerritoryBasedSharing.getAccountsByUserId(territoriesByAccountId);
        for (Id userId : accountsByUserId.keyset()) {
            enableAccountSharing(userId, accountsByUserId.get(userId));
        }
        Map<Id,Set<Id>> contactsByUserId = TerritoryBasedSharing.getContactsByUserId(accountsByUserId);
        for (Id userId : contactsByUserId.keyset()) {
            ContactHandler.enableContactSharing(userId, contactsByUserId.get(userId));
        }
    }

    /* removeAccountAccess method:
        Accept list of accounts
        remove all share rules for accounts and contacts
    */
    public static void removeAccountAccess(List<Account> accounts) {
        List<AccountShare> accountShares = [select Id from AccountShare where AccountId in :accounts and RowCause = 'Manual'];
        List<Reference__c> refs = [select Contact__r.Id,Contact__r.Name from Reference__c where Account__r.Id in :accounts];
        Set<Contact> contacts = new Set<Contact>();
        for(Reference__c ref : refs) { contacts.add(ref.Contact__r); }
        List<ContactShare> contactShares = [select Id from ContactShare where ContactId in :contacts and RowCause = 'Manual'];
        if(accountShares.size() > 0) {
            delete accountShares;
        }
        if(contactShares.size() > 0) {
            delete contactShares;
        }
    }

    /* enableAccountSharing method:
        Accept userID and list of account IDs
        grant Edit permission to user for corresponding accounts
    */
    @future
    public static void enableAccountSharing(Id userId, Set<Id> accountIds) {
        List<AccountShare> accountsToShare = new List<AccountShare>();
        for (Id accId : accountIds) {
            AccountShare accShare = new AccountShare(
                AccountId = accId,
                UserOrGroupId = userId,
                AccountAccessLevel = 'Edit',
                ContactAccessLevel = 'Edit',
                OpportunityAccessLevel = 'None',
                CaseAccessLevel = 'None',
                RowCause = 'Manual'
            );
            accountsToShare.add(accShare);
        }
        if(accountsToShare.size() > 0) {
            insert accountsToShare;
        }
    }
}