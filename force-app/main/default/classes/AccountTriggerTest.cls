@isTest
private class AccountTriggerTest {
    @TestSetup
    private static void dataFactory() {
        user u = new User(
            FirstName         = 'Test',
            LastName          = 'User',
            Username          = ('test.user' + DateTime.now().getTime() + '@foobar.com').toLowerCase(),
            Alias             = 'test',
            Email             = 'test.user@foobar.com',
            ProfileId         = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey  = 'UTF-8',
            TimeZoneSidKey    = 'America/Los_Angeles',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            IsActive          = true
        );
        insert u;
        Account a = new Account(
            Name              = 'Test Account',
            RecordTypeId      = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId(),
            Website           = 'www.foobar.com',
            OwnerId           = UserInfo.getUserId(),
            BillingStreet     = '686 SIXTH AVE',
            BillingCity       = 'New York',
            BillingState      = 'New York',
            BillingPostalCode = '10068',
            BillingCountry    = 'United States'
        );
        insert a;
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact c = new Contact(
                FirstName = 'Test',
                LastName  = ('Contact ' + i),
                Email     = ('Test.Contact' + i + '@foobar.com').toLowerCase(),
                Phone     = '1234567890',
                OwnerId   = a.OwnerId,
                AccountId = a.Id
            );
            contacts.add(c);
        }
        insert contacts;
    }

    @isTest
     private static void test01_update() {
        Account a = [SELECT Id, Name, OwnerId, BillingAddress FROM Account LIMIT 1];
        User u = [SELECT Id, Username, ProfileId FROM User LIMIT 1];
        for (Contact c : [SELECT Id, AccountId, OwnerId FROM Contact]) {
            System.assertNotEquals(c.OwnerId, u.Id);
        }
        Test.startTest();
        System.runAs (u) {
            a.OwnerId           = UserInfo.getUserId();
            a.BillingStreet     = '123 MAIN ST';
            a.BillingCity       = 'Irvine';
            a.BillingState      = 'California';
            a.BillingPostalCode = '91707';
            a.BillingCountry    = 'United States';
            a.BillingLatitude   = 33.7490;
            a.BillingLongitude  = -117.8608;
            update a;
            a.BillingLongitude  = -118.8608;
            update a;
        }
        Test.stopTest();
        for (Contact c : [SELECT Id, AccountId, OwnerId, MailingStreet FROM Contact]) {
            System.assertEquals(c.ownerId, u.Id);
            System.assertEquals(c.MailingStreet, a.BillingStreet);
        }
    }

    @isTest
     private static void test02_validate() {
        Account a = [SELECT Id, Name, Website FROM Account LIMIT 1];
        Test.startTest();
        try {
            a.Website = null;
            update a;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, [SELECT Website FROM Account WHERE Id = :a.Id].Website);
    }

    @isTest
     private static void test03_delete() {
        Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.startTest();
        delete a;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
    }

    @isTest
     private static void test04_undelete() {
        Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.startTest();
        delete a;
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
        undelete a;
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.stopTest();
    }

    @isTest
     private static void test05_prevent_delete() {
        Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #5',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Prospecting',
            Amount      = 100000.00,
            CloseDate   = Date.today().addDays(28),
            Probability = 100,
            Discount__c = 0.05,
            AccountId   = a.Id
        );
        insert o;
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
        Test.startTest();
        try {
            delete a;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
    }
}