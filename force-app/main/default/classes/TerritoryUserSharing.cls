public with sharing class TerritoryUserSharing {
    public static void AddSharing(List<TerritoryUser__c> tUserList) {
        List<Territory__c> territoriesToUpdate = getTerritoryHierarchy(tUserList);
        List<Account> accountsToUpdate = [select Id from Account where Territory__c in :territoriesToUpdate];
        List<AccountShare> accountShare = new List<AccountShare>();

        for (Account acc : accountsToUpdate) {
            AccountShare accShr = new AccountShare(
                AccountId = acc.Id,
                UserOrGroupId = tUserList[0].User__c, // FIXME: does not support multiple sales rep users
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

        List<Contact> contacts = [select Id,Name from Contact where Id in (select Contact__c from Reference__c where Account__c in :accountsToUpdate)];
        List<ContactShare> contactShare = new List<ContactShare>();
        for (Contact cont : contacts) {
            ContactShare shr = new ContactShare(
                ContactId = cont.Id,
                UserOrGroupId = tUserList[0].User__c, // FIXME: does not support multiple sales rep users
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

    public static void RemoveSharing() {
        User salesRep = [select Id,Name from User where Username = 'jdoe_salesrep@test.com'];
        List<Account> accountsToUpdate = [select Id from Account where Territory__c != null];
        List<Contact> contactsToUpdate = [select Id from Contact where Id in (select Contact__c from Reference__c where Account__c in :accountsToUpdate)];
        List<AccountShare> accountShare = [select Id from AccountShare where AccountId in :accountsToUpdate and UserOrGroupId = :salesRep.Id];
        List<ContactShare> contactShare = [select Id from ContactShare where ContactId in :contactsToUpdate and UserOrGroupId = :salesRep.Id];

        Database.DeleteResult[] deleteResults = Database.delete(accountShare,false);
        for(Database.DeleteResult ddr : deleteResults) {
            if (!ddr.isSuccess()) {
                for(Database.Error err : ddr.getErrors()) {
                    System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }

        deleteResults = Database.delete(contactShare,false);
        for(Database.DeleteResult ddr : deleteResults) {
            if (!ddr.isSuccess()) {
                for(Database.Error err : ddr.getErrors()) {
                    System.debug('ERROR: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    //Get assigned Territory and subordinates recursively
    private static List<Territory__c> getTerritoryHierarchy(List<TerritoryUser__c> tUserList) {
        List<Territory__c> topLevels = [select Id,Name from Territory__c where Id in (select Territory__c from TerritoryUser__c where Id in :tUserList)];
        List<Territory__c> territoriesToUpdate = new List<Territory__c>(topLevels);
        List<Territory__c> currentLevel= new List<Territory__c>(topLevels);
        Boolean isDone = false;
        while(!isDone) {
            currentLevel = [select Id,Name,Parent__c from Territory__c where Parent__c in :currentLevel];
            if (currentLevel.size() > 0) {
                territoriesToUpdate.addall(currentLevel);
            } else {
                isDone = true;
            }
        }
        return territoriesToUpdate;
    }
}
