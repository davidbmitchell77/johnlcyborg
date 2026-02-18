@isTest
private class LeadTriggerTest {
    @TestSetup
    private static void dataFactory(){
        Lead l = new Lead(
            FirstName = 'Jane',
            LastName  = 'Doe',
            Company   = 'Test Company #0',
            Email     = 'jane.doe@testcompany0.com',
            Status    = 'Open - Not Contacted'
        );
        insert l;
    }

    @isTest
    private static void test01_insert(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company #1',
            Email     = 'john.doe@testcompany1.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Lead]);
    }

    @isTest
    private static void test02_update(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company #2',
            Email     = 'john.doe@testcompany2.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.FirstName = 'Jane';
        l.LastName = 'Doe';
        l.Email = 'jane.doe@testcompany0.com';
        update l;
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email, Description FROM Lead ORDER BY CreatedDate ASC];
        System.assertEquals(2, leads.size());
        System.assertEquals(System.Label.DUPLICATE_LEAD_RECORD, leads[1].Description);
    }

    @isTest
    private static void test03_delete(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company #3',
            Email     = 'john.doe@testcompany3.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.Industry = 'Entertainment';
        delete l;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Lead]);
    }

    @isTest
    private static void test04_undelete(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company #4',
            Email     = 'john.doe@testcompany4.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.Industry = 'Entertainment';
        delete l;
        System.assertEquals(1, [SELECT COUNT() FROM Lead]);
        undelete l;
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Lead]);
    }

    @isTest
    private static void test05_validate(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company #5',
            Email     = 'john.doe@testcompany5.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.LastName = '';
        l.Email    = '';
        try {
            update l;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, ('LeadTriggerTest.test05: ' + e.getMessage()));
        }
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email FROM Lead];
        System.assertEquals(2, leads.size());
        System.assertNotEquals('', leads[0].LastName);
        System.assertNotEquals('', leads[0].Email);
    }
}