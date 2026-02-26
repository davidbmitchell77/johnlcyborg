trigger UserTrigger on User (before insert, before update, after insert, after update) {
    TriggerSetting__mdt ts = TriggerSetting__mdt.getInstance(Test.isRunningTest() ? 'Test' : 'User');
    Boolean runTriggerHandler = false;

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            runTriggerHandler = ts.BeforeInsert__c;
        }
        when BEFORE_UPDATE {
            runTriggerHandler = ts.BeforeUpdate__c;
        }
        when AFTER_INSERT {
            runTriggerHandler = ts.AfterInsert__c;
        }
        when AFTER_UPDATE {
            runTriggerHandler = ts.AfterUpdate__c;
        }
    }

    if (runTriggerHandler == true) {
        UserTriggerHandler handler = new UserTriggerHandler(Trigger.operationType);
        if (handler.isValid(Trigger.new)) {
            handler.run(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}