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
            Name         = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId(),
            Website      = 'www.foobar.com',
            OwnerId      = UserInfo.getUserId()
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
     private static void test01() {
        User u = [SELECT Id, Username, ProfileId FROM User LIMIT 1];
        for (Contact c : [SELECT Id, AccountId, OwnerId FROM Contact]) {
            System.assertNotEquals(c.OwnerId, u.Id);
        }
        Test.startTest();
        System.runAs (u) {
            Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
            a.OwnerId = UserInfo.getUserId();
            update a;
        }
        Test.stopTest();
        for (Contact c : [SELECT Id, AccountId, OwnerId FROM Contact]) {
            System.assertEquals(c.ownerId, u.Id);
        }
    }

    @isTest
     private static void test02() {
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
     private static void test03() {
        Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.startTest();
        delete a;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
    }

    @isTest
     private static void test04() {
        Account a = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.startTest();
        delete a;
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
        undelete a;
        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        Test.stopTest();
    }
}