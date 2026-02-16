@isTest
private class CaseTriggerTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            Name    = 'Test Account',
            Phone   = '(111) 111-1111',
            Website = 'www.foobar.com'
        );
        insert a;
    }

    @isTest
    private static void test01_insert() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = 'Test Case #1'
        );
        insert c;
        Test.stopTest();
        System.assertEquals(1, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
    }

    @isTest
    private static void test02_update() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = 'Test Case #2'
        );
        insert c;
        System.assertEquals(1, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
        c.Status = 'Closed';
        update c;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
    }

    @isTest
    private static void test03_delete() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = 'Test Case #3'
        );
        insert c;
        System.assertEquals(1, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
        delete c;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
    }

    @isTest
    private static void test04_undelete() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = 'Test Case #4'
        );
        insert c;
        System.assertEquals(1, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
        delete c;
        undelete c;
        Test.stopTest();
        System.assertEquals(1, [SELECT Id, OpenCases__c FROM Account WHERE Id = :a.Id LIMIT 1].OpenCases__c);
    }

    @isTest
    private static void test05_validate() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = null
        );
        try {
            insert c;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, 'CaseTriggerTest.test05_validate(): ' + e.getMessage());
        }
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Id = :a.Id]);
    }

    @isTest
    private static void test06_dmlException() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        Case c = new Case(
            AccountId = a.Id,
            Subject   = 'Test Case #6'
        );
        insert c;
        try {
            a.Name = null;
            update a;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, 'CaseTriggerTest.test06_dmlException(): ' + e.getMessage());
        }
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Id = :a.Id]);
    }
}