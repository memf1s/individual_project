trigger contactTrigger on Contact (after insert, before update, after update, before delete, after undelete) {
    if(userinfo.getProfileId() != '00e09000001EulcAAC') { // do not run triggers when account is changed by Salesrep
        if (trigger.isBefore) {
            if(trigger.isUpdate || trigger.isDelete) {
                ContactHandler.removeContactAccess(trigger.old);
            }
        } else if(trigger.isAfter) {
            if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
                ContactHandler.addContactAccess(trigger.new);
            }
        }
    }
}