trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerSetting__mdt ts = TriggerSetting__mdt.getInstance(Test.isRunningTest() ? 'Test' : 'Lead');
    Boolean runTriggerHandler = false;

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            runTriggerHandler = ts.BeforeInsert__c;
        }
        when BEFORE_UPDATE {
            runTriggerHandler = ts.BeforeUpdate__c;
        }
        when BEFORE_DELETE {
            runTriggerHandler = ts.BeforeDelete__c;
        }
        when AFTER_INSERT {
            runTriggerHandler = ts.AfterInsert__c;
        }
        when AFTER_UPDATE {
            runTriggerHandler = ts.AfterUpdate__c;
        }
        when AFTER_DELETE {
            runTriggerHandler = ts.AfterDelete__c;
        }
        when AFTER_UNDELETE {
            runTriggerHandler = ts.AfterUndelete__c;
        }
    }

    if (runTriggerHandler == true) {
        LeadTriggerHandler handler = new LeadTriggerHandler(Trigger.operationType);
        if (handler.isValid(Trigger.new)) {
            handler.run(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}