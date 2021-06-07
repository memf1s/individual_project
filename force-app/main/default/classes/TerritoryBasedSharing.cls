public with sharing class TerritoryBasedSharing {

    /*  getAccountsByUserId method:
        accepts a map of territories by account Id
        returns a map of account Ids by User Id
    */
    public static Map<Id,Set<Id>> getAccountsByUserId(Map<Id,Set<Territory__c>> territoriesByAccountId) {
        Set<Territory__c> allTerritories = new Set<Territory__c>();
        for(Set<Territory__c> terr : territoriesByAccountId.values()) {
            allTerritories.addall(terr);
        }
        List<TerritoryUser__c> tUsers = [
            select Id, User__c, Territory__r.Id, Territory__r.Name, Territory__r.Parent__c
            from TerritoryUser__c where Territory__c in :allTerritories
        ];
        Map<Id,Set<Id>> accountsByUserId = new Map<Id,Set<Id>>();
        for (TerritoryUser__c tUser : tUsers) {
            if (!accountsByUserId.containsKey(tUser.User__c)) {
                accountsByUserId.put(tUser.User__c, new Set<Id>());
            }
            for (Id acctId : territoriesByAccountId.keyset()) {
                if(territoriesByAccountId.get(acctId).contains(tUser.Territory__r)) {
                    accountsByUserId.get(tUser.User__c).add(acctId);
                }
            }
        }
        return accountsByUserId;
    }

    /*  getContactsByUserId method (overloaded):
        accepts a map of account Ids by User Id
        returns a map of contact Ids by User Id
    */
    public static Map<Id,Set<Id>> getContactsByUserId(Map<Id,Set<Id>> accountsByUserId) {
        Set<Id> allAccountIds = new Set<Id> ();
        for (Id userId : accountsByUserId.keyset()) {
            allAccountIds.addall(accountsByUserId.get(userId));
        }
        List<Reference__c> references = [select Account__r.Id,Account__r.Territory__c, Contact__r.Id from Reference__c where Account__r.Id in :allAccountIds];
        return getContactsByUserId(accountsByUserId, references);
    }

    /*  getContactsByUserId method (overloaded):
        accepts a map of account Ids by User Id and list of Reference__c
        returns a map of contact Ids by User Id
    */
    public static Map<Id,Set<Id>> getContactsByUserId(Map<Id,Set<Id>> accountsByUserId, List<Reference__c> references) {
        Map<Id,Set<Id>> contactsByUserId = new Map<Id,Set<Id>> ();

        for (Id userId : accountsByUserId.keyset()) {
            if (!contactsByUserId.containsKey(userId)) {
                contactsByUserId.put(userId, new Set<Id>());
            }
            for (Reference__c ref : references) {
                if(accountsByUserId.get(userId).contains(ref.Account__r.Id)) {
                    contactsByUserId.get(userId).add(ref.Contact__r.Id);
                }
            }
        }
        return contactsByUserId;
    }

    /*  getTerritoriesByAccount method:
        accepts a list of account objects
        returns a map of assigned and parent territories by account ID
    */
    public static Map<Id,Set<Territory__c>> getTerritoriesByAccount(List<Account> accounts) {
        List<Territory__c> assignedTerritories = new List<Territory__c> ([
            select Id,Name,Parent__c from Territory__c where
            Id in (select Territory__c from Account where Id in :accounts)
        ]);
        // loop through method result to avoid duplicates during map conversion
        for (Territory__c territory : findParentTerritories(assignedTerritories)) {
            if (!assignedTerritories.contains(territory)) {
                assignedTerritories.add(territory);
            }
        }
        Map<Id,Territory__c> territoryMap = new Map<Id,Territory__c>(assignedTerritories);

        Map<Id,Set<Territory__c>> territoriesByAccountId = new Map<Id,Set<Territory__c>> ();
        for (Account acct : accounts) {
            if (!territoriesByAccountId.containsKey(acct.Id)) {
                territoriesByAccountId.put(acct.Id, new Set<Territory__c>());
                territoriesByAccountId.get(acct.Id).add( territoryMap.get(acct.Territory__c) );
            }
            Territory__c accountTerritory = territoryMap.get(acct.Territory__c);
            while(accountTerritory.Parent__c != null) {
                accountTerritory = territoryMap.get(accountTerritory.Parent__c);
                territoriesByAccountId.get(acct.Id).add( territoryMap.get(accountTerritory.Id) );
            }
        }
        return territoriesByAccountId;
    }

    /*  findParentTerritories method:
        accepts a List of territories for look up
        returns a List of all parents for each territory
    */
    private static List<Territory__c> findParentTerritories(List<Territory__c> territories) {
        List<Territory__c> parentTerritories = new List<Territory__c>(); // result set of unique parent territories
        List<Territory__c> parentLevel = territories; // starting point for lookup
        Boolean isDone = false;
        while(!isDone) { // get parents for current level
            List<Territory__c> currentLevel = [
                select Id, Name, Parent__r.Id, Parent__r.Name, Parent__r.Parent__c
                from Territory__c where Id in :parentLevel];
            if (currentLevel.size() > 0) {
                parentLevel = new List<Territory__c> (); // create new set of parents and re-populate it
                for (Territory__c tmpTerritory : currentLevel) {
                    if (tmpTerritory.Parent__c != null) {
                        parentLevel.add(tmpTerritory.Parent__r);
                    }
                }
                parentTerritories.addall(parentLevel); // add parents to result
            } else {
                isDone = true;
            }
        }
        return parentTerritories;
    }

    /*  findSubTerritories method:
        accepts a List of territories for look up
        returns a List of all subordinate territories
    */
    public static List<Territory__c> findSubTerritories(List<Territory__c> territories) {
        List<Territory__c> subTerritories = territories; // result set of unique sub territories
        List<Territory__c> currentLevel = territories; // starting point for lookup
        Boolean isDone = false;
        while(!isDone) { // get territories with parent in current level
            currentLevel = [select Id,Name,Parent__c from Territory__c where Parent__c in :currentLevel];
            if (currentLevel.size() > 0) {
                subTerritories.addall(currentLevel);
            } else {
                isDone = true;
            }
        }
        return subTerritories;
    }
}