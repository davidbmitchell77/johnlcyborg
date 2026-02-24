@isTest
private class OpportunityTriggerTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            Name    = 'Test Account',
            Phone   = '(000) 000-0000',
            Website = 'www.testaccount.com'
        );
        insert a;
    }

    @isTest
    private static void test01_insert() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #1',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Prospecting',
            Amount      = 100000.00,
            Probability = 100,
            Type        = 'New Business',
            CloseDate   = Date.today().addDays(28),
            AccountId   = a.Id
        );
        Test.startTest();
        insert o;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
    }

    @isTest
    private static void test02_update() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #2',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Prospecting',
            Amount      = 100000.00,
            Type        = 'New Business',
            CloseDate   = Date.today().addDays(28),
            AccountId   = a.Id
        );
        Test.startTest();
        insert o;
        o.StageName = 'Closed Won';
        update o;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
        System.assertEquals(true, [SELECT IsClosed FROM Opportunity WHERE Id = :o.Id LIMIT 1].IsClosed);
        System.assertEquals(o.Amount, [SELECT Id, MaxOptyAmount__c FROM Account LIMIT 1].MaxOptyAmount__c);
    }

    @isTest
    private static void test03_delete() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #3',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Closed Won',
            Amount      = 100000.00,
            Type        = 'New Business',
            CloseDate   = Date.today().addDays(28),
            AccountId   = a.Id
        );
        Test.startTest();
        insert o;
        System.assertEquals(o.Amount, [SELECT Id, MaxOptyAmount__c FROM Account LIMIT 1].MaxOptyAmount__c);
        delete o;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity]);
        System.assertEquals(0, [SELECT Id, MaxOptyAmount__c FROM Account LIMIT 1].MaxOptyAmount__c);
    }

    @isTest
    private static void test04_undelete() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #4',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Closed Won',
            Amount      = 100000.00,
            Type        = 'New Business',
            CloseDate   = Date.today().addDays(28),
            AccountId   = a.Id,
            Probability = 100
        );
        Test.startTest();
        insert o;
        delete o;
        undelete o;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
        System.assertEquals(o.Amount, [SELECT Id, MaxOptyAmount__c FROM Account LIMIT 1].MaxOptyAmount__c);
    }

    @isTest
    private static void test05_validate() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #5',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Prospecting',
            Amount      = 100000.00,
            Type        = 'New Business',
            CloseDate   = null,
            AccountId   = a.Id
        );
        Test.startTest();
        try {
            insert o;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, ('OpportunityTriggerTest.test05_validate(): ' + e.getMessage()));
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity]);
    }
}