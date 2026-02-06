public class InfinitusAPIIntegration {
    private static final String className = 'InfinitusAPIIntegration';

    @InvocableMethod(label='Send Care Benefit Verification Request')
    public static void send(List<Id> cbvrIds) {
        CareBenefitVerifyRequest__c result = new CareBenefitVerifyRequest__c();
        httpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(System.JSON.serialize(cbvRequest(cbvrIds)));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            InfinitusHttpResponseWrapper wrapper = InfinitusHttpResponseWrapper.parse(res.getBody());
            result.Status__c = wrapper.status;
            result.StatusReason__c = wrapper.statusReason;
            System.debug(Logginglevel.INFO, (className + ': ' + res.getStatusCode() + '|' + description(res.getStatusCode())));
        }
        else {
            result.Status__c = String.valueOf(res.getStatusCode());
            result.StatusReason__c = (className + ': ' + res.getStatusCode() + '|' + description(res.getStatusCode()));
            System.debug(Logginglevel.ERROR, (result.StatusReason__c));
        }
    }

    private static String convert(CareBenefitVerifyRequest__c cbvr) {
        String result = '';
        InfinitusHttpRequestWrapper.RequestDetails requestDetails = new InfinitusHttpRequestWrapper.RequestDetails();
        InfinitusHttpRequestWrapper.PatientDetails patientDetails = new InfinitusHttpRequestWrapper.PatientDetails();
        InfinitusHttpRequestWrapper.InsuranceInformation insuranceInformation = new InfinitusHttpRequestWrapper.InsuranceInformation();
        InfinitusHttpRequestWrapper.ProviderInformation providerInformation = new InfinitusHttpRequestWrapper.ProviderInformation();
        InfinitusHttpRequestWrapper.ServiceDetails serviceDetails = new InfinitusHttpRequestWrapper.ServiceDetails();
        InfinitusHttpRequestWrapper wrapper = new InfinitusHttpRequestWrapper();
        requestDetails.requestId          = cbvr.Name;
        requestDetails.requestDate        = cbvr.LastModifiedDate.format('yyyy-MM-dd');
        patientDetails.firstName          = cbvr.PatientFirstName__c;
        patientDetails.lastName           = cbvr.PatientLastName__c;
        patientDetails.dateOfBirth        = ((Datetime)cbvr.DateOfBirth__c).format('yyyy-MM-dd');
        insuranceInformation.providerName = cbvr.InsuranceProvider__c;
        insuranceInformation.policyNumber = cbvr.PolicyNumber__c;
        insuranceInformation.groupNumber  = cbvr.GroupNumber__c;
        insuranceInformation.subscriberId = cbvr.SubscriberId__c;
        providerInformation.npi           = cbvr.NPI__c;
        providerInformation.firstName     = cbvr.ProviderFirstName__c;
        providerInformation.lastName      = cbvr.ProviderLastName__c;
        serviceDetails.serviceType        = cbvr.ServiceType__c;
        serviceDetails.serviceDate        = ((Datetime)cbvr.ServiceDate__c).format('yyyy-MM-dd');
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
                       SubscriberId__c
                  FROM CareBenefitVerifyRequest__c
                 WHERE Id IN :cbvrIds
        ][0];
    }

    private static String description(Integer statusCode) {
        String result = '';
        switch on statusCode {
            when 100  { result = 'Continue';              }
            when 101  { result = 'Switching Protocols';   }
            when 200  { result = 'OK';                    }
            when 201  { result = 'Created';               }
            when 204  { result = 'No Content';            }
            when 301  { result = 'Moved Permanently';     }
            when 302  { result = 'Found';                 }
            when 400  { result = 'Bad Request';           }
            when 401  { result = 'Unauthorized';          }
            when 403  { result = 'Forbidden';             }
            when 404  { result = 'Not Found';             }
            when 405  { result = 'Method Not Allowed';    }
            when 429  { result = 'Too Many Requests';     }
            when 500  { result = 'Internal Server Error'; }
            when 503  { result = 'Service Unavailable';   }
            when else { result = 'Unknown Status Code';   }
        }
        return result;
    }
}