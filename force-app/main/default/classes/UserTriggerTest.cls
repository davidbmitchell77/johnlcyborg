@isTest
private class UserTriggerTest {
    @TestSetup
    static void dataFactory(){

    }

    @isTest
    private static void test01_insert(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            Alias             = 'test1',
            Email             = 'test.user1@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            FirstName         = 'Test',
            LastName          = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'test.user1@testorg.com'
        );
        Test.startTest();
        insert u;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM User WHERE Id = :u.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
    }

    @isTest
    private static void test02_update(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(
            Alias             = 'test2',
            Email             = 'test.user2@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            FirstName         = 'Test',
            LastName          = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'test.user2@testorg.com'
        );
        Test.startTest();
        insert u;
        System.assertEquals(1, [SELECT COUNT() FROM User WHERE Id = :u.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        update u;
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        update u;
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
        Test.stopTest();
    }

    @isTest
    private static void test03_deactivate(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            Alias             = 'test3',
            Email             = 'test.user3@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            FirstName         = 'Test',
            LastName          = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'test.user3@testorg.com'
        );
        Test.startTest();
        insert u;
        System.assertEquals(1, [SELECT COUNT() FROM User WHERE Id = :u.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
        u.IsActive = false;
        update u;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
    }

    @isTest
    private static void test04_reactivate(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            Alias             = 'test4',
            Email             = 'test.user4@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            FirstName         = 'Test',
            LastName          = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'test.user4@testorg.com'
        );
        Test.startTest();
        insert u;
        System.assertEquals(1, [SELECT COUNT() FROM User WHERE Id = :u.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
        u.IsActive = false;
        update u;
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
        Test.stopTest();
        u.IsActive = true;
        update u;
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins' AND UserOrGroupId = :u.Id]);
    }

    @isTest
    private static void test05_validate(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            Alias             = 'test1',
            Email             = 'test.user1@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            FirstName         = 'Test',
            LastName          = '',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'test.user1@testorg.com'
        );
        Test.startTest();
        try {
            insert u;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'UserTriggerTest.test05_validate: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM User WHERE Username = :u.Username]);
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE Group.Name = 'Admins']);
    }
}