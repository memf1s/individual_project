trigger referenceTrigger on Reference__c (after insert, before update, after update, before delete, after undelete) {
    if (trigger.isBefore) {
        if(trigger.isUpdate || trigger.isDelete) {
            ReferenceHandler.removeReferenceAccess(trigger.old);
        }
    } else if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
            ReferenceHandler.addReferenceAccess(trigger.new);
        }
    }
}