public class InfinitusAPIIntegration {
    private static final String className = 'InfinitusAPIIntegration';
    private static final String yyyymmdd  = 'yyyy-MM-dd';

    @InvocableMethod(label='Send Care Benefit Verification Request' category='Infinitus' description='Send a Care Benefit Verification Request to Infinitus.')
    public static void send(List<Id> cbvrIds) {
        if (cbvrIds != null) {
            for (Id cbvrId : cbvrIds) {
                if (cbvrId != null) {
                    sendAsynchronous(cbvrId);
                }
            }
        }
    }

    @future(callout=true)
    public static void sendAsynchronous(Id cbvrId) {
        CareBenefitVerifyRequest__c cbvr = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c WHERE Id = :cbvrId];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(stringify(cbvRequest(cbvrId)));
        req.setTimeout(10000);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            InfinitusHttpResponseWrapper wrapper = InfinitusHttpResponseWrapper.parse(res.getBody());
            cbvr.Status__c = wrapper.status;
            cbvr.StatusReason__c = wrapper.statusReason;
            updateCBVRecord(cbvr);
            System.debug(Logginglevel.INFO, ('HTTP_STATUS: ' + res.getStatusCode()));
            System.debug(Logginglevel.INFO, System.JSON.serializePretty(wrapper));
        }
        else {
            cbvr.Status__c = String.valueOf(res.getStatusCode());
            cbvr.StatusReason__c = (res.getStatusCode() + '|' + description(res.getStatusCode()));
            updateCBVRecord(cbvr);
            System.debug(Logginglevel.ERROR, ('HTTP_STATUS: ' + res.getStatusCode()));
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

    @TestVisible
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
        String result = (String.valueOf(statusCode) + '|');
        switch on statusCode {
            when 100  { result += 'CONTINUE';                        }
            when 101  { result += 'SWITCHING PROTOCOLS';             }
            when 102  { result += 'PROCESSING';                      }
            when 103  { result += 'EARLY HINTS';                     }
            when 200  { result += 'OK';                              }
            when 201  { result += 'CREATED';                         }
            when 202  { result += 'ACCEPTED';                        }
            when 203  { result += 'NON-AUTHORITATIVE INFORMATION';   }
            when 204  { result += 'NO CONTENT';                      }
            when 205  { result += 'RESET CONTENT';                   }
            when 206  { result += 'PARTIAL CONTENT';                 }
            when 207  { result += 'MULTI-STATUS';                    }
            when 208  { result += 'ALREADY REPORTED';                }
            when 226  { result += 'IM USED';                         }
            when 300  { result += 'MULTIPLE CHOICES';                }
            when 301  { result += 'MOVED PERMANENTLY';               }
            when 302  { result += 'FOUND';                           }
            when 303  { result += 'SEE OTHER';                       }
            when 304  { result += 'NOT MODIFIED';                    }
            when 305  { result += 'USE PROXY';                       }
            when 306  { result += 'SWITCH PROXY';                    }
            when 307  { result += 'TEMPORARY REDIRECT';              }
            when 308  { result += 'PERMANENT REDIRECT';              }
            when 400  { result += 'BAD REQUEST';                     }
            when 401  { result += 'UNAUTHORIZED';                    }
            when 403  { result += 'FORBIDDEN';                       }
            when 404  { result += 'NOT FOUND';                       }
            when 405  { result += 'METHOD NOT ALLOWED';              }
            when 406  { result += 'NOT ACCEPTABLE';                  }
            when 407  { result += 'PROXY AUTHENTICATION REQUIRED';   }
            when 408  { result += 'REQUEST TIMEOUT';                 }
            when 409  { result += 'CONFLICT';                        }
            when 410  { result += 'GONE';                            }
            when 411  { result += 'LENGTH REQUIRED';                 }
            when 412  { result += 'PRECONDITION FAILED';             }
            when 413  { result += 'CONTENT TOO LARGE';               }
            when 414  { result += 'URI TOO LONG';                    }
            when 415  { result += 'UNSUPPORTED MEDIA TYPE';          }
            when 416  { result += 'RANGE NOT SATISFIABLE';           }
            when 417  { result += 'EXPECTATION FAILED';              }
            when 418  { result += 'I AM A TEAPOT';                   }
            when 421  { result += 'MISDIRECTED REQUEST';             }
            when 422  { result += 'UNPROCESSABLE ENTITY';            }
            when 423  { result += 'LOCKED';                          }
            when 424  { result += 'FAILED DEPENDENCY';               }
            when 425  { result += 'TOO EARLY';                       }
            when 426  { result += 'UPGRADE REQUIRED';                }
            when 428  { result += 'PRECONDITION REQUIRED';           }
            when 429  { result += 'TOO MANY REQUESTS';               }
            when 431  { result += 'REQUEST HEADER FIELDS TOO LARGE'; }
            when 451  { result += 'UNAVAILABLE FOR LEGAL REASONS';   }
            when 500  { result += 'INTERNAL SERVER ERROR';           }
            when 501  { result += 'NOT IMPLEMENTED';                 }
            when 502  { result += 'BAD GATEWAY';                     }
            when 503  { result += 'SERVICE UNAVAILABLE';             }
            when 504  { result += 'GATEWAY TIMEOUT';                 }
            when 505  { result += 'HTTP VERSION NOT SUPPORTED';      }
            when 506  { result += 'VARIANT ALSO NEGOTIATES';         }
            when 507  { result += 'INSUFFICIENT STORAGE';            }
            when 508  { result += 'LOOP DETECTED';                   }
            when 510  { result += 'NOT EXTENDED';                    }
            when 511  { result += 'NETWORK AUTHENTICATION REQUIRED'; }
            when else { result += 'UNKNOWN STATUS CODE';             }
        }
        return result;
    }
}