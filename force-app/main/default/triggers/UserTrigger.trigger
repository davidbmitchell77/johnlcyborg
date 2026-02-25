trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Boolean runTriggerHandler = false;

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            runTriggerHandler = false;
        }
        when BEFORE_UPDATE {
            runTriggerHandler = false;
        }
        when BEFORE_DELETE {
            runTriggerHandler = false;
        }
        when AFTER_INSERT {
            runTriggerHandler = true;
        }
        when AFTER_UPDATE {
            runTriggerHandler = true;
        }
        when AFTER_DELETE {
            runTriggerHandler = true;
        }
        when AFTER_UNDELETE {
            runTriggerHandler = true;
        }
    }

    if (runTriggerHandler == true) {
        UserTriggerHandler handler = new UserTriggerhandler(Trigger.operationType);
        if (handler.isValid(Trigger.new)) {
            handler.run(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}