public class InfinitusAPIIntegration {
    private static final String className = 'InfinitusAPIIntegration';
    private static final String yyyymmdd  = 'yyyy-MM-dd';

    @InvocableMethod(label='Send Care Benefit Verification Request' category='Infinitus' description='Send a Care Benefit Verification Request to Infinitus.')
    public static void send(List<Id> cbvrIds) {
        CareBenefitVerifyRequest__c result = new CareBenefitVerifyRequest__c();
        httpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(stringify(cbvRequest(cbvrIds)));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            InfinitusHttpResponseWrapper wrapper = InfinitusHttpResponseWrapper.parse(res.getBody());
            result.Status__c = wrapper.status;
            result.StatusReason__c = wrapper.statusReason;
            updateCBVRecord(result);
            System.debug(Logginglevel.INFO, (className + ': ' + res.getStatusCode() + '|' + description(res.getStatusCode())));
        }
        else {
            result.Status__c = String.valueOf(res.getStatusCode());
            result.StatusReason__c = (res.getStatusCode() + '|' + description(res.getStatusCode()));
            System.debug(Logginglevel.ERROR, (className + ': ' + result.StatusReason__c));
        }
    }

    private static String stringify(CareBenefitVerifyRequest__c cbvr) {
        String result = '';
        InfinitusHttpRequestWrapper.RequestDetails requestDetails = new InfinitusHttpRequestWrapper.RequestDetails();
        InfinitusHttpRequestWrapper.PatientDetails patientDetails = new InfinitusHttpRequestWrapper.PatientDetails();
        InfinitusHttpRequestWrapper.InsuranceInformation insuranceInformation = new InfinitusHttpRequestWrapper.InsuranceInformation();
        InfinitusHttpRequestWrapper.ProviderInformation providerInformation = new InfinitusHttpRequestWrapper.ProviderInformation();
        InfinitusHttpRequestWrapper.ServiceDetails serviceDetails = new InfinitusHttpRequestWrapper.ServiceDetails();
        InfinitusHttpRequestWrapper wrapper = new InfinitusHttpRequestWrapper();
        requestDetails.requestId          = cbvr.Name;
        requestDetails.requestDate        = cbvr.LastModifiedDate.format(yyyymmdd);
        patientDetails.firstName          = cbvr.PatientFirstName__c;
        patientDetails.lastName           = cbvr.PatientLastName__c;
        patientDetails.dateOfBirth        = ((Datetime)cbvr.DateOfBirth__c).format(yyyymmdd);
        insuranceInformation.providerName = cbvr.InsuranceProvider__c;
        insuranceInformation.policyNumber = cbvr.PolicyNumber__c;
        insuranceInformation.groupNumber  = cbvr.GroupNumber__c;
        insuranceInformation.subscriberId = cbvr.SubscriberId__c;
        providerInformation.npi           = cbvr.NPI__c;
        providerInformation.firstName     = cbvr.ProviderFirstName__c;
        providerInformation.lastName      = cbvr.ProviderLastName__c;
        serviceDetails.serviceType        = cbvr.ServiceType__c;
        serviceDetails.serviceDate        = ((Datetime)cbvr.ServiceDate__c).format(yyyymmdd);
        serviceDetails.diagnosisCode      = cbvr.DiagnosisCode__c;
        serviceDetails.procedureCode      = cbvr.ProcedureCode__c;
        wrapper.rd                        = requestDetails;
        wrapper.pd                        = patientDetails;
        wrapper.ii                        = insuranceInformation;
        wrapper.pi                        = providerInformation;
        wrapper.sd                        = serviceDetails;
        result                            = System.JSON.serialize(wrapper);
        return result;
    }

    private static CareBenefitVerifyRequest__c cbvRequest(List<Id> cbvrIds) {
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
                       ProviderFirstName__c,
                       ProviderLastName__c,
                       ServiceDate__c,
                       ServiceType__c,
                       Status__c,
                       StatusReason__c,
                       SubscriberId__c,
                       LastModifiedDate
                  FROM CareBenefitVerifyRequest__c
                 WHERE Id IN :cbvrIds
        ][0];
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