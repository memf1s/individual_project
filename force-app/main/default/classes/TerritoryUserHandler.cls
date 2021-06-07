public with sharing class TerritoryUserHandler {
    
    public static void addTUserAccess(List<TerritoryUser__c> tUsers) {
        List<Territory__c> territories = new List<Territory__c> ();
        for (TerritoryUser__c tUser : tUsers) {
            territories.add(new Territory__c( Id = tUser.Territory__c));
        }
        territories = TerritoryBasedSharing.findSubTerritories(territories);
        List<Account> accounts = [select Id,Territory__c from Account where Territory__c in :territories];
        AccountHandler.addAccountAccess(accounts);
    }

    public static void removeTUserAccess(List<TerritoryUser__c> tUsers) {
        List<Territory__c> territories = new List<Territory__c> ();
        for (TerritoryUser__c tUser : tUsers) {
            territories.add(new Territory__c( Id = tUser.Territory__c));
        }
        territories = TerritoryBasedSharing.findSubTerritories(territories);
        List<Account> accounts = [select Id,Territory__c from Account where Territory__c in :territories];
        AccountHandler.removeAccountAccess(accounts);
    }
}