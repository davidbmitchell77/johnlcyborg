@isTest
private class LeadTriggerTest {
    @TestSetup
    private static void dataFactory(){
        Lead l = new Lead(
            FirstName = 'Jane',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'jane.doe@testcompany.com',
            Status    = 'Open - Not Contacted'
        );
        insert l;
    }

    @isTest
    private static void test01(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'john.doe@testcompany.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Lead]);
    }

    @isTest
    private static void test02(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'john.doe@testcompany.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.FirstName = 'Jane';
        l.LastName = 'Doe';
        l.Email = 'jane.doe@testcompany.com';
        update l;
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email, Description FROM Lead ORDER BY CreatedDate ASC];
        System.assertEquals(2, leads.size());
        System.assertEquals(System.Label.DUPLICATE_LEAD_RECORD, leads[1].Description);
    }

    @isTest
    private static void test03(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'john.doe@testcompany.com',
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
            System.debug(LoggingLevel.ERROR, ('LeadTriggerTest.test03: ' + e.getMessage()));
        }
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email FROM Lead];
        System.assertEquals(2, leads.size());
        System.assertNotEquals('', leads[0].LastName);
        System.assertNotEquals('', leads[0].Email);
    }

    @isTest
    private static void test04(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'john.doe@testcompany.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.Industry = 'Entertainment';
        delete l;
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email FROM Lead];
        System.assertEquals(1, leads.size());
    }

    @isTest
    private static void test05(){
        Lead l = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Company   = 'Test Company',
            Email     = 'john.doe@testcompany.com',
            Status    = 'Open - Not Contacted'
        );
        Test.startTest();
        insert l;
        l.Industry = 'Entertainment';
        delete l;
        undelete l;
        Test.stopTest();
        List<Lead> leads = [SELECT Id, LastName, Email FROM Lead];
        System.assertEquals(2, leads.size());
    }
}