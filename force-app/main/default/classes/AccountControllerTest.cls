@isTest
private class AccountControllerTest {
    @TestSetup
    public static void dataFactory() {
        MemberPlan__c memberPlan = new MemberPlan__c(
            Name                 = 'Test Member Plan',
            SubscriberId__c      = UUID.randomUUID().toString(),
            GroupNumber__c       = UUID.randomUUID().toString(),
            PolicyNumber__c      = UUID.randomUUID().toString()
        );
        insert memberPlan;
        Account provider = new Account(
            RecordTypeId         = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId(),
            Salutation__c        = 'Dr.',
            Name                 = 'Test Provider',
            ProviderSuffix__c    = 'MD',
            Gender__c            = 'Female',
            NPI__c               = '0000000001',
            Rating               = 'Good',
            Website              = 'www.provider.net',
            Active__c            = 'True'
        );
        insert provider;
        Account patient = new Account(
            RecordTypeId         = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId(),
            Salutation__c        = 'Dr.',
            Name                 = 'Test Patient',
            DateOfBirth__c       = Date.today().addYears(-30),
            Gender__c            = 'Male',
            Active__c            = 'True',
            Website              = 'www.patient.com',
            MemberPlan__c        = memberPlan.Id,
            Provider__c          = provider.Id
        );
        insert patient;
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact c = new Contact(
                FirstName = UUID.randomUUID().toString(),
                LastName  = ('0000' + String.valueOf(i + 1)).right(4),
                Phone     = '(000) 000-0000',
                AccountId = patient.Id
            );
            contacts.add(c);
        }
        insert contacts;
    }

    @isTest
    private static void test01_getAccounts() {
        Test.startTest();
        List<Account> accounts = AccountsController.getAccounts();
        Test.stopTest();
        System.assertNotEquals(0, accounts.size());
    }

    @isTest
    private static void test02_getContacts() {
        Account a = [SELECT Id, Name, Website FROM Account WHERE RecordType.DeveloperName  = 'Patient' LIMIT 1];
        Test.startTest();
        List<Contact> contacts = AccountsController.getContacts(a.Id);
        Test.stopTest();
        System.assertEquals(10, contacts.size());
    }
}