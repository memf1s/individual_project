public with sharing class TerritoryHandler {
    
    public static void addTerritoryAccess(List<Territory__c> territories) {
        List<Account> accounts = [select Id,Territory__c from Account where Territory__c in :territories];
        AccountHandler.addAccountAccess(accounts);
    }

    public static void removeTerritoryAccess(List<Territory__c> territories) {
        List<Account> accounts = [select Id,Territory__c from Account where Territory__c in :territories];
        AccountHandler.removeAccountAccess(accounts);
    }
}