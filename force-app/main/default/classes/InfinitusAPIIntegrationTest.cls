@isTest
private class InfinitusAPIIntegrationTest {
    @TestSetup
    private static void dataFactory() {
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
    }

    @isTest
    private static void test01_http_ok() {
        Account patient = [SELECT Id, Name, DateOfBirth__c, Gender__c, MemberPlan__c, Provider__c FROM Account WHERE RecordType.DeveloperName = 'Patient' LIMIT 1];
        Account provider = [SELECT Id, Name, NPI__c FROM Account WHERE RecordType.DeveloperName = 'Provider' LIMIT 1];
        MemberPlan__c memberPlan = [SELECT Id, Name, SubscriberId__c, GroupNumber__c, PolicyNumber__c FROM MemberPlan__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new InfinitusHttpResponseGenerator(200));
        Test.startTest();
        ServiceDetail__c serviceDetail = new ServiceDetail__c(
            MasterDetailToAccount__c  = patient.Id,
            ServiceDate__c            = Date.today(),
            Type__c                   = 'Consultation',
            DiagnosisCode__c          = 'E11.9',
            ProcedureCode__c          = '99213'
        );
        insert serviceDetail;
        Test.stopTest();
        List<CareBenefitVerifyRequest__c> cbvRequests = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c];
        System.assertEquals(1, cbvRequests.size());
        System.assertEquals('Acknowledged', cbvRequests[0].Status__c);
        System.assertEquals(1, [SELECT COUNT() FROM CareBenefitVerification__c WHERE CareBenefitVerificationRequest__c = :cbvRequests[0].Id]);
    }

    @isTest
    private static void test02_http_error() {
        Account patient = [SELECT Id, Name, DateOfBirth__c, Gender__c, MemberPlan__c, Provider__c FROM Account WHERE RecordType.DeveloperName = 'Patient' LIMIT 1];
        Account provider = [SELECT Id, Name, NPI__c FROM Account WHERE RecordType.DeveloperName = 'Provider' LIMIT 1];
        MemberPlan__c memberPlan = [SELECT Id, Name, SubscriberId__c, GroupNumber__c, PolicyNumber__c FROM MemberPlan__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new InfinitusHttpResponseGenerator(999));
        Test.startTest();
        ServiceDetail__c serviceDetail = new ServiceDetail__c(
            MasterDetailToAccount__c  = patient.Id,
            ServiceDate__c            = Date.today(),
            Type__c                   = 'Consultation',
            DiagnosisCode__c          = 'E11.9',
            ProcedureCode__c          = '99213'
        );
        insert serviceDetail;
        Test.stopTest();
        List<CareBenefitVerifyRequest__c> cbvRequests = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c];
        System.assertEquals(1, cbvRequests.size());
        System.assertEquals('999', cbvRequests[0].Status__c);
    }

    @isTest
    private static void test03_dml_exception() {
        Account patient = [SELECT Id, Name, DateOfBirth__c, Gender__c, MemberPlan__c, Provider__c FROM Account WHERE RecordType.DeveloperName = 'Patient' LIMIT 1];
        Account provider = [SELECT Id, Name, NPI__c FROM Account WHERE RecordType.DeveloperName = 'Provider' LIMIT 1];
        MemberPlan__c memberPlan = [SELECT Id, Name, SubscriberId__c, GroupNumber__c, PolicyNumber__c FROM MemberPlan__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new InfinitusHttpResponseGenerator(200));
        Test.startTest();
        ServiceDetail__c serviceDetail = new ServiceDetail__c(
            MasterDetailToAccount__c  = patient.Id,
            ServiceDate__c            = Date.today(),
            Type__c                   = 'Consultation',
            DiagnosisCode__c          = 'E11.9',
            ProcedureCode__c          = '99213'
        );
        insert serviceDetail;
        List<CareBenefitVerifyRequest__c> cbvRequests = [SELECT Id, Name, ServiceType__c, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c];
        cbvRequests[0].ServiceType__c = null;
        try {
            InfinitusAPIIntegration.updateCBVRecord(cbvRequests[0]);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, ('InfinitusAPIIntegrationTest.test03: ' + e.getMessage()));
        }
        Test.stopTest();
        System.assertEquals(1, cbvRequests.size());
        System.assertEquals('Not Submitted', cbvRequests[0].Status__c);
    }
}