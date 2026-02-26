public with sharing class OpportunityTriggerHandler {
    private final TriggerOperation operationType;
    private final String           apexClassName;
    private final String           closedWon;

    public OpportunityTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.apexClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        this.closedWon     = System.Label.OPPORTUNITY_STAGE_CLOSED_WON;
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
                updateParentAccounts(null, newOptys, null, newMap);
            }
            when AFTER_UPDATE {
                updateParentAccounts(oldOptys, newOptys, oldMap, newMap);
            }
            when AFTER_DELETE {
                updateParentAccounts(oldOptys, null, oldMap, null);
            }
            when AFTER_UNDELETE {
                updateParentAccounts(null, newOptys, null, newMap);
            }
        }
    }

    private void updateParentAccounts(List<Opportunity> oldOptys, List<Opportunity> newOptys, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        Map<Id,Account> accounts = new Map<Id,Account>();
        for (Id accountId : accountIds(oldOptys, newOptys, oldMap, newMap)) {
            accounts.put(accountId, new Account(Id=accountId, MaxOptyAmount__c=0.00));
        }

        for (AggregateResult agr : [SELECT AccountId, MAX(Amount) maxOptyAmount
                                      FROM Opportunity
                                     WHERE AccountId IN :accounts.keySet()
                                      WITH SYSTEM_MODE
                                  GROUP BY AccountId
        ]) {
            Account a = new Account(Id=(Id)agr.get('AccountId'), MaxOptyAmount__c=(Decimal)agr.get('maxOptyAmount'));
            accounts.put(a.Id, a);
        }

        if (!accounts.values().isEmpty()) {
            for (Database.SaveResult sr : Database.update(accounts.values(), false, AccessLevel.SYSTEM_MODE)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.apexClassName + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }

    private Set<Id> accountIds(List<Opportunity> oldOptys, List<Opportunity> newOptys, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        Set<Id> results = new Set<Id>();
        for (Opportunity o : nvl(newOptys, oldOptys)) {
            Boolean addToResults = false;
            if (o.AccountId != null) {
                switch on this.operationType {
                    when AFTER_INSERT, AFTER_DELETE, AFTER_UNDELETE {
                      if (o.StageName == this.closedWon) {
                            addToResults = true;
                      }
                    }
                    when AFTER_UPDATE {
                        Opportunity oldOpty = oldMap.get(o.Id);
                        Opportunity newOpty = newMap.get(o.Id);
                        if (oldOpty.StageName != newOpty.StageName) {
                            if (oldOpty.StageName == this.closedWon || newOpty.StageName == this.closedWon) {
                                addToResults = true;
                            }
                        }
                    }
                }
             }
             if (addToResults == true) {
                 if (!results.contains(o.AccountId)) {
                     results.add(o.AccountId);
                 }
             }
         }
        return results;
    }

    private List<Opportunity> nvl(List<Opportunity> list1, List<Opportunity> list2) {
        return ((list1 != null) ? list1 : list2);
    }
}