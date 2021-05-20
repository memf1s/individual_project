trigger territoryUserTrigger on TerritoryUser__c (after insert, before update, after update, before delete, after delete, after undelete) {
    if(trigger.isInsert || trigger.isUndelete) {
        TerritoryBasedSharing.addSharing(trigger.new);
    }
    if (trigger.isBefore) {
        if(trigger.isUpdate || trigger.isDelete) {
            TerritoryBasedSharing.removeSharing(trigger.old);
        }
    } else if (trigger.isAfter) {
        if(trigger.isUpdate || trigger.isDelete) {
            List<TerritoryUser__c> tUsers = [select User__c,Territory__c from TerritoryUser__c];
            TerritoryBasedSharing.addSharing(tUsers);
        }
    }

}