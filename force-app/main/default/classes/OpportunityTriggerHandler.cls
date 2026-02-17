public with sharing class OpportunityTriggerHandler {
    private final TriggerOperation operationType;
    private final String           className;

    public OpportunityTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className     = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public Boolean isValid(List<Opportunity> opportunities) {
        Boolean result = true;
        if (opportunities != null) {
            for (Opportunity o : opportunities) {
                if (String.isBlank(o.Description)) {
                    o.Description.addError(System.Label.OPPORTUNITY_DESCRIPTION_IS_REQUIRED);
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