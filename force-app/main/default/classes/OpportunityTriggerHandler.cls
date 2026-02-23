public with sharing class OpportunityTriggerHandler {
    private final TriggerOperation operationType;
    private final String           apexClassName;

    public OpportunityTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.apexClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public Boolean isValid(List<Opportunity> opportunities) {
        Boolean result = true;
        if (opportunities != null) {
            for (Opportunity o : opportunities) {
                if (o.CloseDate == null) {
                    o.CloseDate.addError(System.Label.OPPORTUNITY_CLOSE_DATE_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<Opportunity> oldOptys, List<Opportunity> newOptys, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        switch on this.operationType {
            when BEFORE_INSERT {

            }
            when BEFORE_UPDATE {

            }
            when BEFORE_DELETE {

            }
            when AFTER_INSERT {

            }
            when AFTER_UPDATE {

            }
            when AFTER_DELETE {

            }
            when AFTER_UNDELETE {

            }
        }
    }
}