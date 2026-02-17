public with sharing class ContactTriggerHandler {
    private final TriggerOperation operationType;
    private final String           className;

    public ContactTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.className     = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public Boolean isValid(List<Contact> contacts) {
        Boolean result = true;
        if (contacts != null) {
            for (Contact c : contacts) {
                if (String.isBlank(c.Phone)) {
                    c.Phone.addError(System.Label.CONTACT_PHONE_NUMBER_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    public void run(List<Contact> oldContacts, List<Contact> newContacts, Map<Id,Contact> oldMap, Map<Id,Contact> newMap) {
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