public with sharing class AccountTriggerHandler {
    private final TriggerOperation operationType;
    private final String           className;

    public AccountTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className     = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public Boolean isValid(List<Account> accounts) {
        Boolean result = true;
        if (accounts != null) {
            for (Account a : accounts) {
                if (String.isBlank(a.Website)) {
                    a.Website.addError(System.Label.ACCOUNT_WEBSITE_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<Account> oldAccounts, List<Account> newAccounts, Map<Id,Account> oldMap, Map<Id,Account> newMap) {
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
                updateChildContacts(oldAccounts, newAccounts, oldMap, newMap);
            }
            when AFTER_DELETE {

            }
            when AFTER_UNDELETE {

            }
        }
    }

    private void updateChildContacts(List<Account> oldAccounts, List<Account> newAccounts, Map<Id,Account> oldMap, Map<Id,Account> newMap) {
        List<Contact> contacts = new List<Contact>();

        for (Contact c : [SELECT Id, AccountId, OwnerId
                            FROM Contact
                           WHERE AccountId IN :newMap.keySet()
                            WITH SYSTEM_MODE
        ]) {
            if (c.OwnerId != newMap.get(c.AccountId).OwnerId) {
                c.OwnerId = newMap.get(c.AccountId).OwnerId;
                contacts.add(c);
            }
        }

        if (!contacts.isEmpty()) {
            for (Database.SaveResult sr : Database.update(contacts, false)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.className + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }
}