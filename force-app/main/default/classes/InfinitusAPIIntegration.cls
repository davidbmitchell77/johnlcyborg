public class InfinitusAPIIntegration {
    private static final String className = 'InfinitusAPIIntegration';
    private static final String yyyymmdd  = 'yyyy-MM-dd';

    @InvocableMethod(label='Send Care Benefit Verification Request' category='Infinitus' description='Send a Care Benefit Verification Request to Infinitus.')
    public static void send(List<Id> cbvrIds) {
        sendAsynchronous(cbvrIds[0]);
    }

  //@future(callout=true)
    public static void sendAsynchronous(Id cbvrId) {
        CareBenefitVerifyRequest__c cbvr = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c WHERE Id = :cbvrId];
        httpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(stringify(cbvRequest(cbvrId)));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            InfinitusHttpResponseWrapper wrapper = InfinitusHttpResponseWrapper.parse(res.getBody());
            cbvr.Status__c = wrapper.status;
            cbvr.StatusReason__c = wrapper.statusReason;
            updateCBVRecord(cbvr);
            System.debug(Logginglevel.INFO, ('HTTP STATUS: ' + res.getStatusCode()));
            System.debug(Logginglevel.INFO, System.JSON.serializePretty(wrapper));
        }
        else {
            cbvr.Status__c = String.valueOf(res.getStatusCode());
            cbvr.StatusReason__c = (res.getStatusCode() + '|' + description(res.getStatusCode()));
            System.debug(Logginglevel.ERROR, (className + ': ' + cbvr.StatusReason__c));
        }
    }

    private static String stringify(CareBenefitVerifyRequest__c cbvr) {
        String result = '';
        InfinitusHttpRequestWrapper.rd requestDetails = new InfinitusHttpRequestWrapper.rd();
        InfinitusHttpRequestWrapper.pd patientDetails = new InfinitusHttpRequestWrapper.pd();
        InfinitusHttpRequestWrapper.ii insuranceInformation = new InfinitusHttpRequestWrapper.ii();
        InfinitusHttpRequestWrapper.pi providerInformation = new InfinitusHttpRequestWrapper.pi();
        InfinitusHttpRequestWrapper.sd serviceDetails = new InfinitusHttpRequestWrapper.sd();
        InfinitusHttpRequestWrapper wrapper = new InfinitusHttpRequestWrapper();
        requestDetails.requestId          = cbvr.Name;
        requestDetails.requestDate        = cbvr.LastModifiedDate.format(yyyymmdd);
        patientDetails.firstName          = cbvr.PatientFirstName__c;
        patientDetails.lastName           = cbvr.PatientLastName__c;
        patientDetails.gender             = cbvr.Gender__c;
        patientDetails.dateOfBirth        = ((Datetime)cbvr.DateOfBirth__c).format(yyyymmdd);
        insuranceInformation.providerName = cbvr.InsuranceProvider__c;
        insuranceInformation.policyNumber = cbvr.PolicyNumber__c;
        insuranceInformation.groupNumber  = cbvr.GroupNumber__c;
        insuranceInformation.subscriberId = cbvr.SubscriberId__c;
        providerInformation.npi           = cbvr.NPI__c;
        providerInformation.salutation    = cbvr.ProviderSalutation__c;
        providerInformation.firstName     = cbvr.ProviderFirstName__c;
        providerInformation.lastName      = cbvr.ProviderLastName__c;
        serviceDetails.serviceType        = cbvr.ServiceType__c;
        serviceDetails.serviceDate        = ((Datetime)cbvr.ServiceDate__c).format(yyyymmdd);
        serviceDetails.diagnosisCode      = cbvr.DiagnosisCode__c;
        serviceDetails.procedureCode      = cbvr.ProcedureCode__c;
        wrapper.RequestDetails            = requestDetails;
        wrapper.PatientDetails            = patientDetails;
        wrapper.InsuranceInformation      = insuranceInformation;
        wrapper.ProviderInformation       = providerInformation;
        wrapper.ServiceDetails            = serviceDetails;
        result                            = System.JSON.serializePretty(wrapper);
        System.debug(Logginglevel.INFO, result);
        return result;
    }

    private static CareBenefitVerifyRequest__c cbvRequest(Id cbvrId) {
        return [SELECT Name,
                       DateOfBirth__c,
                       DiagnosisCode__c,
                       Gender__c,
                       GroupNumber__c,
                       InsuranceProvider__c,
                       NPI__c,
                       PatientFirstName__c,
                       PatientLastName__c,
                       PolicyNumber__c,
                       ProcedureCode__c,
                       ProviderSalutation__c,
                       ProviderFirstName__c,
                       ProviderLastName__c,
                       ServiceDate__c,
                       ServiceType__c,
                       Status__c,
                       StatusReason__c,
                       SubscriberId__c,
                       LastModifiedDate
                  FROM CareBenefitVerifyRequest__c
                 WHERE Id = :cbvrId
                 LIMIT 1
        ];
    }

    private static void updateCBVRecord(CareBenefitVerifyRequest__c cbvRecord) {
        for (Database.SaveResult sr : Database.update(new List<CareBenefitVerifyRequest__c>{ cbvRecord }, false)) {
            if (!sr.isSuccess()) {
                for (Database.Error e : sr.getErrors()) {
                    System.debug(Logginglevel.ERROR, (className + ': ' + e.getStatusCode() + '|' + e.getMessage()));
                }
                throw new DMLException(System.Label.ERROR_UPDATING_CARE_BENEFIT_VERIFY_REQUEST_RECORD);
            }
        }
    }

    private static String description(Integer statusCode) {
        String result = '';
        switch on statusCode {
            when 100  { result = 'CONTINUE';              }
            when 101  { result = 'SWITCHING PROTOCOLS';   }
            when 200  { result = 'OK';                    }
            when 201  { result = 'CREATED';               }
            when 204  { result = 'NO CONTENT';            }
            when 301  { result = 'MOVED PERMANENTLY';     }
            when 302  { result = 'FOUND';                 }
            when 400  { result = 'BAD REQUEST';           }
            when 401  { result = 'UNAUTHORIZED';          }
            when 403  { result = 'FORBIDDEN';             }
            when 404  { result = 'NOT FOUND';             }
            when 405  { result = 'METHOD NOT ALLOWED';    }
            when 429  { result = 'TOO MANY REQUESTS';     }
            when 500  { result = 'INTERNAL SERVER ERROR'; }
            when 503  { result = 'SERVICE UNAVAILABLE';   }
            when else { result = 'UNKNOWN STATUS CODE';   }
        }
        return result;
    }
}