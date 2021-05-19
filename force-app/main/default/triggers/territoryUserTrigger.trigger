trigger territoryUserTrigger on TerritoryUser__c (after insert, after update, after delete, after undelete) {
    if(trigger.isInsert || trigger.isUndelete) {
        TerritoryUserSharing.AddSharing(trigger.new);
    } else if (trigger.isUpdate) {
        TerritoryUserSharing.RemoveSharing();
        List<TerritoryUser__c> tUser = [select User__c, Territory__c from TerritoryUser__c];
        TerritoryUserSharing.AddSharing(tUser);
    } else if (trigger.isDelete) {
        TerritoryUserSharing.RemoveSharing();
        List<TerritoryUser__c> tUser = [select User__c, Territory__c from TerritoryUser__c];
        TerritoryUserSharing.AddSharing(tUser);
    }

}