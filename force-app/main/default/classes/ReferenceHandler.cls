public with sharing class ReferenceHandler {

    public static void addReferenceAccess(List<Reference__c> refs) {
        List<Reference__c> references = [select Account__r.Id,Account__r.Territory__c, Contact__r.Id from Reference__c where Id in :refs];
        List<Account> accounts = new List<Account>();
        for(Reference__c ref : references) {
             accounts.add(ref.Account__r);
        }
        AccountHandler.addAccountAccess(accounts);
    }
    
    public static void removeReferenceAccess(List<Reference__c> refs) {
        List<Reference__c> references = [select Account__r.Id,Account__r.Territory__c, Contact__r.Id from Reference__c where Id in :refs];
        List<Account> accounts = new List<Account>();
        for(Reference__c ref : references) {
             accounts.add(ref.Account__r);
        }
        AccountHandler.removeAccountAccess(accounts);
    }
}