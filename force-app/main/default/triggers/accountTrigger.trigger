trigger accountTrigger on Account (after insert, before update, after update, before delete, after undelete) {
    if(userinfo.getProfileId() != '00e09000001EulcAAC') { // do not run triggers when account is changed by SalesRep
        if (trigger.isBefore) {
            if(trigger.isUpdate || trigger.isDelete) {
                AccountHandler.removeAccountAccess(trigger.old);
            }
        } else if(trigger.isAfter) {
            if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
                AccountHandler.addAccountAccess(trigger.new);
            }
        }
    }
}