trigger territoryTrigger on Territory__c (after insert, before update, after update, before delete, after undelete) {
    if (trigger.isBefore) {
        if(trigger.isUpdate || trigger.isDelete) {
            TerritoryHandler.removeTerritoryAccess(trigger.old);
        }
    } else if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
            TerritoryHandler.addTerritoryAccess(trigger.new);
        }
    }
}