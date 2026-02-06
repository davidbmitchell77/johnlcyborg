public class LeadTriggerHandler {
    private final TriggerOperation operationType;
    private final String className;
    private final String userIdPrefix;

    public LeadTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className     = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        this.userIdPrefix  = User.SObjectType.getDescribe().getKeyPrefix();
    }

    public Boolean isValid(List<Lead> leads) {
        Boolean result = true;
        if (leads != null) {
            for (Lead l : leads) {
                if (String.isBlank(l.LastName)) {
                    l.LastName.addError(System.Label.LEAD_LAST_NAME_IS_REQUIRED);
                    result = false;
                }
                if (String.isBlank(l.Email)) {
                    l.Email.addError(System.Label.LEAD_EMAIL_ADDRESS_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<Lead> oldLeads, List<Lead> newLeads, Map<Id,Lead> oldMap, Map<Id,Lead> newMap) {
         switch on this.operationType {
             when BEFORE_INSERT {
                checkForDuplicateLeads(oldLeads, newLeads, oldMap, newMap);
             }
             when BEFORE_UPDATE {
                checkForDuplicateLeads(oldLeads, newLeads, oldMap, newMap);
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

    public void checkForDuplicateLeads(List<Lead> oldLeads, List<Lead> newLeads, Map<Id,Lead> oldMap, Map<Id,Lead> newMap) {
        Map<String,Lead> duplicates = new Map<String,Lead>();

        for (Lead l : [SELECT Id, LastName, Email, OwnerId
                         FROM Lead
                        WHERE (LastName IN :lastNames(newLeads) OR Email IN :emailAddresses(newLeads))
        ]) {
            duplicates.put((l.Email + '|' + l.LastName).toLowerCase(), l);
        }

        for (Lead l : newLeads) {
            String dupKey = (l.Email + '|' + l.LastName).toLowerCase();
            if (duplicates.containsKey(dupKey)) {
                l.Description = System.Label.DUPLICATE_LEAD_RECORD;
                Lead duplicateLead = duplicates.get(dupKey);
                if (prefix(duplicateLead.OwnerId) == this.userIdPrefix) {
                    l.OwnerId = duplicateLead.OwnerId;
                }
            }
        }
    }

    private Set<String> emailAddresses(List<Lead> leads) {
        Set<String> results = new Set<String>();
        if (leads != null) {
            for (Lead l : leads) {
                if (!String.isBlank(l.Email)) {
                    if (!results.contains(l.Email.toLowerCase())) {
                        results.add(l.Email.toLowerCase());
                    }
                }
            }
        }
        return results;
    }

    private Set<String> lastNames(List<Lead> leads) {
        Set<String> results = new Set<String>();
        if (leads != null) {
            for (Lead l : leads) {
                if (!String.isBlank(l.LastName)) {
                    if (!results.contains(l.LastName.toLowerCase())) {
                        results.add(l.LastName.toLowerCase());
                    }
                }
            }
        }
        return results;
    }

    private String prefix(Id recordId) {
        return String.valueof(recordId).substring(0,3);
    }
}