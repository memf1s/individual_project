trigger territoryUserTrigger on TerritoryUser__c (after insert, before update, after update, before delete, after delete, after undelete) {
    if (trigger.isBefore) {
        if(trigger.isUpdate || trigger.isDelete) {
            TerritoryUserHandler.removeTUserAccess(trigger.old);
        }
    } else if(trigger.isAfter) {
        if(trigger.isDelete) {
            TerritoryUserHandler.addTUserAccess(trigger.old);
        } else if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
            TerritoryUserHandler.addTUserAccess(trigger.new);
        }
    }
}