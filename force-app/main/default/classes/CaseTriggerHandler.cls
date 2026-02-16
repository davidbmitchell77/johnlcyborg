public with sharing class CaseTriggerHandler {
    private final TriggerOperation operationType;
    private final String           className;

    public CaseTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className     = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public Boolean isValid(List<Case> cases) {
        Boolean result = true;
        if (cases != null) {
            for (Case c : cases) {
                if (String.isBlank(c.Subject)) {
                    c.Subject.addError(System.Label.CASE_SUBJECT_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<Case> oldCases, List<Case> newCases, Map<Id,Case> oldMap, Map<Id,Case> newMap) {
        switch on this.operationType {
            when BEFORE_INSERT {

            }
            when BEFORE_UPDATE {

            }
            when BEFORE_DELETE {

            }
            when AFTER_INSERT {
                updateParentAccounts(null, newCases, null, newMap);
            }
            when AFTER_UPDATE {
                updateParentAccounts(oldCases, newCases, oldMap, newMap);
            }
            when AFTER_DELETE {
                updateParentAccounts(oldCases, null, oldMap, null);
            }
            when AFTER_UNDELETE {
                updateParentAccounts(null, newCases, null, newMap);
            }
        }
    }

    private void updateParentAccounts(List<Case> oldCases, List<Case> newCases, Map<Id,Case> oldMap, Map<Id,Case> newMap) {
        Map<Id,Account> accounts = new Map<Id,Account>();
        for (Id accountId : accountIds(nvl(newCases, oldCases))) {
            accounts.put(accountId, new Account(Id=accountId, OpenCases__c=0));
        }

        for (AggregateResult agr : [SELECT AccountId, COUNT(Id) openCases
                                      FROM Case
                                     WHERE AccountId IN :accountIds(nvl(newCases, oldCases))
                                       AND IsClosed = false
                                      WITH SYSTEM_MODE
                                  GROUP BY AccountId
        ]) {
            Account a = new Account(Id=(Id)agr.get('AccountId'), OpenCases__c=(Integer)agr.get('openCases'));
            accounts.put(a.Id, a);
        }

        if (!accounts.values().isEmpty()) {
            for (Database.SaveResult sr : Database.update(accounts.values(), false)) {
                if (!sr.isSuccess()) { for (Database.error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.className + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }

    private Set<Id> accountIds(List<Case> cases) {
        Set<Id> results = new Set<Id>();
        if (cases != null) {
            for (Case c : cases) {
                if (c.AccountId != null) {
                    if (!results.contains(c.AccountId)) {
                        results.add(c.AccountId);
                    }
                }
            }
        }
        return results;
    }

    private List<Case> nvl(List<Case> list1, List<Case> list2) {
        return ((list1 != null) ? list1 : list2);
    }
}