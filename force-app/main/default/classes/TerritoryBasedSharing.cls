public with sharing class TerritoryBasedSharing {
    public static void addSharing(List<TerritoryUser__c> todoList) {
        Map<Id,Set<Territory__c>> territoriesPerUser = prepareUsersList(todoList);
        for(Id user: territoriesPerUser.keySet()) {
            List<Account> accountsToUpdate = [select Id,Name from Account where Territory__c in :territoriesPerUser.get(user)];
            enableAccountSharing(user, accountsToUpdate);
        }
    }

    public static void enableAccountSharing(Id user, List<Account> accountsList) {
        List<AccountShare> accountShare = new List<AccountShare>();

        for (Account acc : accountsList) {
            AccountShare accShr = new AccountShare(
                AccountId = acc.Id,
                UserOrGroupId = user,
                AccountAccessLevel = 'Edit',
                ContactAccessLevel = 'Edit',
                OpportunityAccessLevel = 'None',
                CaseAccessLevel = 'None'
            );
            accountShare.add(accShr);
        }
        Database.SaveResult[] saveResults = Database.insert(accountShare,false);
        for(Database.SaveResult dsr : saveResults) {
            if (!dsr.isSuccess()) {
                for(Database.Error err : dsr.getErrors()) {
                    System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }

        List<Reference__c> refs = [select Contact__r.Id,Contact__r.Name from Reference__c where Account__c in :accountsList];
        List<ContactShare> contactShare = new List<ContactShare>();
        for (Reference__c ref : refs) {
            ContactShare shr = new ContactShare(
                ContactId = ref.Contact__c,
                UserOrGroupId = user,
                ContactAccessLevel = 'Edit'
            );
            contactShare.add(shr);
        }
        saveResults = Database.insert(contactShare,false);
        for(Database.SaveResult dsr : saveResults) {
            if (!dsr.isSuccess()) {
                for(Database.Error err : dsr.getErrors()) {
                    System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public static void removeSharing(List<TerritoryUser__c> todoList) {
        Map<Id,Set<Territory__c>> territoriesPerUser = prepareUsersList(todoList);
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<ContactShare> contactShareList = new List<ContactShare>();
        for(Id user: territoriesPerUser.keySet()) {

            List<Account> accountsToUpdate = [select Id,Name from Account where Territory__c in :territoriesPerUser.get(user)];
            List<AccountShare> accSharetmp = [select Id from AccountShare where AccountId in :accountsToUpdate and UserOrGroupId = :user];
            if(accSharetmp.size() > 0) {
                accountShareList.addall(accSharetmp);
            }

            List<Reference__c> refs = [select Contact__r.Id,Contact__r.Name from Reference__c where Account__r.Id in :accountsToUpdate];
            List<Contact> contacts = new List<Contact>();
            for(Reference__c ref : refs) { contacts.add(ref.Contact__r); }
            List<ContactShare> contSharetmp = [select Id from ContactShare where ContactId in :contacts and UserOrGroupId = :user];
            if(contSharetmp.size() > 0) {
                contactShareList.addall(contSharetmp);
            }
        }
        if(accountShareList.size() > 0) {
            Database.DeleteResult[] deleteResults = Database.delete(accountShareList,false);
            for(Database.DeleteResult ddr : deleteResults) {
                if (!ddr.isSuccess()) {
                    for(Database.Error err : ddr.getErrors()) {
                        System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if(contactShareList.size() > 0) {
            Database.DeleteResult[] deleteResults = Database.delete(contactShareList,false);
            for(Database.DeleteResult ddr : deleteResults) {
                if (!ddr.isSuccess()) {
                    for(Database.Error err : ddr.getErrors()) {
                        System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }

    private static Map<Id,Set<Territory__c>> prepareUsersList(List<TerritoryUser__c> todoList) {
        List<TerritoryUser__c> tUsersList = [select User__c, Territory__r.Id,Territory__r.Name,Territory__r.Parent__c from TerritoryUser__c where Id in :todoList];
        Map<Id,Set<Territory__c>> territoriesPerUser = new Map<Id,Set<Territory__c>>();
        Set<Id> uniqueUsers = new Set<Id>();
        for(TerritoryUser__c usr : tUsersList) {
            uniqueUsers.add((Id)usr.User__c);
        }
        for(ID usr : uniqueUsers) {
            List<Territory__c> territories = new List<Territory__c>();
            for (TerritoryUser__c tUser : tUsersList) {
                if(usr == tUser.User__c) {
                    territories.add(tUser.Territory__r);
                }
            }
            territoriesPerUser.put(usr,new Set<Territory__c>(getSubTerritories(territories)));
        }
        return territoriesPerUser;
    }

    private static List<Territory__c> getSubTerritories(List<Territory__c> territories) {
        List<Territory__c> hierarchy = new List<Territory__c>(territories);
        List<Territory__c> currentLevel= new List<Territory__c>(territories);
        Boolean isDone = false;
        while(!isDone) {
            currentLevel = [select Id,Name,Parent__c from Territory__c where Parent__c in :currentLevel];
            if (currentLevel.size() > 0) {
                hierarchy.addall(currentLevel);
            } else {
                isDone = true;
            }
        }
        return hierarchy;
    }
}
