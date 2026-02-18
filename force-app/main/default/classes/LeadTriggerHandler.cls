public with sharing class LeadTriggerHandler {
    private final TriggerOperation operationType;
    private final String className;

    public LeadTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
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
                flagDuplicateLeads(null, newLeads, null, null);
            }
            when BEFORE_UPDATE {
                flagDuplicateLeads(oldLeads, newLeads, oldMap, newMap);
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
                flagDuplicateLeads(null, newLeads, null, newMap);
            }
        }
    }

    private void flagDuplicateLeads(List<Lead> oldLeads, List<Lead> newLeads, Map<Id,Lead> oldMap, Map<Id,Lead> newMap) {
        List<Lead> leads = new List<Lead>();

        Set<String> duplicates = new Set<String>();
        for (AggregateResult agr : [SELECT LastName, Email, COUNT(Id)
                                      FROM Lead
                                     WHERE (LastName IN :lastNames(newLeads) OR Email IN :emailAddresses(newLeads))
                                      WITH SYSTEM_MODE
                                  GROUP BY LastName, Email
        ]) {
            if (!String.isBlank((String)agr.get('LastName'))) {
                if (!String.isBlank((String)agr.get('Email'))) {
                    if (!duplicates.contains(dupKey(agr))) {
                        duplicates.add(dupKey(agr));
                    }
                }
            }
        }

        for (Lead l : newLeads) {
            if (!String.isBlank(l.LastName)) {
                if (!String.isBlank(l.Email)) {
                    String s = (duplicates.contains(dupKey(l)) ? 'This is a duplicate lead record.' : 'No duplicate records found.');
                    switch on this.operationType {
                        when BEFORE_INSERT, BEFORE_UPDATE {
                            l.Description = s;
                        }
                        when AFTER_UNDELETE {
                            leads.add(new Lead(Id=l.Id, Description=s));
                        }
                    }
                }
            }
        }

        if (!leads.isEmpty()) {
            for (Database.SaveResult sr : Database.update(leads, false, AccessLevel.SYSTEM_MODE)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.className + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }

    private String dupKey(AggregateResult agr) {
        String result = '';
        result += ((String)agr.get('LastName')).trim().toLowerCase();
        result += '|';
        result += ((String)agr.get('Email')).trim().toLowerCase();
        return result;
    }

    private String dupKey(Lead l) {
        String result = '';
        result += l.LastName.trim().toLowerCase();
        result += '|';
        result += l.Email.trim().toLowerCase();
        return result;
    }

    private Set<String> lastNames(List<Lead> leads) {
        Set<String> results = new Set<String>();
        if (leads != null) {
            for (Lead l : leads) {
                if (!String.isEmpty(l.LastName)) {
                    String s = l.LastName.trim().toLowerCase();
                    if (!results.contains(s)) {
                        results.add(s);
                    }
                }
            }
        }
        return results;
    }

    private Set<String> emailAddresses(List<Lead> leads) {
        Set<String> results = new Set<String>();
        if (leads != null) {
            for (Lead l : leads) {
                if (!String.isEmpty(l.Email)) {
                    String s = l.Email.trim().toLowerCase();
                    if (!results.contains(s)) {
                        results.add(s);
                    }
                }
            }
        }
        return results;
    }
}