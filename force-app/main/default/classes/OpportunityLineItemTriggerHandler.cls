public with sharing class OpportunityLineItemTriggerHandler {
    private final TriggerOperation operationType;
    private final String           apexClassName;

    public OpportunityLineItemTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.apexClassName = SYS_UTILS.apexClassName(String.valueOf(this));
    }

    public Boolean isValid(List<OpportunityLineItem> lineItems) {
        Boolean result = true;
        if (lineItems != null) {
            for (OpportunityLineItem li : lineItems) {
                if (nvl(li.Quantity, 0.00) == 0.00) {
                    li.Name.addError(System.Label.OPPORTUNITY_LINE_ITEM_QUANTITY_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<OpportunityLineItem> oldItems, List<OpportunityLineItem> newItems, Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap) {
        switch on this.operationType {
            when BEFORE_INSERT {
                sequenceLineItems(null, newItems, null, null);
            }
            when BEFORE_UPDATE {

            }
            when BEFORE_DELETE {

            }
            when AFTER_INSERT {
                updateParentAccounts(null, newItems, null, newMap);
            }
            when AFTER_UPDATE {

            }
            when AFTER_DELETE {
                resequenceLineItems(oldItems, null, oldMap, null);
                updateParentAccounts(oldItems, null, oldMap, null);
            }
        }
    }

    private void sequenceLineItems(List<OpportunityLineItem> oldItems, List<OpportunityLineItem> newItems, Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap) {
        Map<Id,Integer> i = new Map<Id,Integer>();
        for (OpportunityLineItem li : newItems) {
            if (li.OpportunityId != null) {
                if (!i.containsKey(li.OpportunityId)) {
                    i.put(li.OpportunityId, 0);
                }
            }
        }

        for (AggregateResult agr : [SELECT OpportunityId, MAX(LineItem__c) maxLineItem
                                      FROM OpportunityLineItem
                                     WHERE opportunityId IN :i.keySet()
                                      WITH SYSTEM_MODE
                                  GROUP BY OpportunityId
        ]) {
            i.put((Id)agr.get('OpportunityId'), ((Decimal)agr.get('maxLineItem')).intValue());
        }

        for (OpportunityLineItem li : newItems) {
            li.LineItem__c = (i.get(li.OpportunityId) + 1);
            i.put(li.OpportunityId, (Integer)li.LineItem__c);
        }
    }


    private void resequenceLineItems(List<OpportunityLineItem> oldItems, List<OpportunityLineItem> newItems, Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap) {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();

        Map<Id,Integer> iMap = new Map<Id,Integer>();
        for (OpportunityLineItem li : nvl(newItems, oldItems)) {
            if (li.OpportunityId != null) {
                if (!iMap.containsKey(li.OpportunityId)) {
                    iMap.put(li.OpportunityId, 0);
                }
            }
        }

        for (AggregateResult agr : [SELECT OpportunityId, MAX(LineItem__c) maxLineItem
                                      FROM OpportunityLineItem
                                     WHERE OpportunityId IN :iMap.keySet()
                                      WITH SYSTEM_MODE
                                  GROUP BY OpportunityId
        ]) {
            iMap.put((Id)agr.get('OpportunityId'), ((Decimal)agr.get('maxLineItem')).intValue());
        }

        Integer i = 0;
        for (OpportunityLineItem li : [SELECT Id, OpportunityId, LineItem__c
                                         FROM OpportunityLineItem
                                        WHERE OpportunityId IN :iMap.keySet()
                                         WITH SYSTEM_MODE
                                     ORDER BY Id ASC
        ]) {
            li.LineItem__c = iMap.get(li.OpportunityId) + 1;
            iMap.put(li.OpportunityId, (Integer)li.LineItem__c);
            lineItems.add(li);
        }

        if (!lineItems.isEmpty()) {
            for (Database.SaveResult sr : Database.update(lineItems, false, AccessLevel.SYSTEM_MODE)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.apexClassName + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }

    private void updateParentAccounts(List<OpportunityLineItem> oldItems, List<OpportunityLineItem> newItems, Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap) {
        Map<Id,Account> accounts = new Map<Id,Account>();
        for (Id accountId : accountIds(opportunities(opportunityIds(nvl(newItems, oldItems))))) {
            accounts.put(accountId, new Account(Id=accountId, OpportunityLineItems__c=0));
        }

        for (AggregateResult agr : [SELECT Opportunity.AccountId, COUNT(Id) lineItems
                                      FROM OpportunityLineItem
                                     WHERE Opportunity.AccountId IN :accounts.keySet()
                                      WITH SYSTEM_MODE
                                  GROUP BY Opportunity.AccountId
        ]) {
            Account a = new Account(Id=(Id)agr.get('AccountId'), OpportunityLineItems__c=(Integer)agr.get('lineItems'));
            accounts.put(a.Id, a);
        }

        if (!accounts.values().isEmpty()) {
            for (Database.SaveResult sr : Database.update(accounts.values(), false, AccessLevel.SYSTEM_MODE)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.apexClassName + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }

    private Set<Id> accountIds(List<Opportunity> opportunities) {
        Set<Id> results = new Set<Id>();
        if (opportunities != null) {
            for (Opportunity o : opportunities) {
                if (o.AccountId != null) {
                    if (!results.contains(o.AccountId)) {
                        results.add(o.AccountId);
                    }
                }
            }
        }
        return results;
    }

    private List<Opportunity> opportunities(Set<Id> optyIds) {
        return [SELECT Id, AccountId FROM Opportunity WHERE Id IN :optyIds WITH SYSTEM_MODE];
    }

    private Set<Id> opportunityIds(List<OpportunityLineItem> lineItems) {
        Set<Id> results = new Set<Id>();
        if (lineItems != null) {
            for (OpportunityLineItem li : lineItems) {
                if (li.OpportunityId != null) {
                    if (!results.contains(li.OpportunityId)) {
                        results.add(li.OpportunityId);
                    }
                }
            }
        }
        return results;
    }

    private Decimal nvl(Decimal d, Decimal defaultValue) {
        return ((d != null) ? d : defaultValue);
    }

    private List<OpportunityLineItem> nvl(List<OpportunityLineItem> list1, List<OpportunityLineItem> list2) {
        return ((list1 != null) ? list1 : list2);
    }
}