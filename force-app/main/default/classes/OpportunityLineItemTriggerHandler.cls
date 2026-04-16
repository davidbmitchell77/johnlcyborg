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
                resequenceLineItems(null, newItems, null, newMap);
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
        Integer i = 0;
        try {
             i = (Integer)[SELECT Id, LineItem__c
                             FROM OpportunityLineItem
                            WHERE OpportunityId IN :opportunityIds(newItems)
                             WITH SYSTEM_MODE
                         ORDER BY LineItem__c DESC
                            LIMIT 1
            ].LineItem__c;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, (this.apexclassName + ': ' + e.getMessage()));
        }

        for (OpportunityLineItem li : newItems) {
            li.LineItem__c = ++i;
        }
    }

    private void resequenceLineItems(List<OpportunityLineItem> oldItems, List<OpportunityLineItem> newItems, Map<Id,OpportunityLineItem> oldMap, Map<Id,OpportunityLineItem> newMap) {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();

        Integer i = 0;
        for (OpportunityLineItem li : [SELECT Id, LineItem__c
                                         FROM OpportunityLineItem
                                        WHERE Id IN :nvl(newMap, oldMap).keySet()
                                         WITH SYSTEM_MODE
                                     ORDER BY Id ASC
        ]) {
            li.LineItem__c = ++i;
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

    private Map<Id,OpportunityLineItem> nvl(Map<Id,OpportunityLineItem> map1, Map<Id,OpportunityLineItem> map2) {
        return ((map1 != null) ? map1 : map2);
    }
}