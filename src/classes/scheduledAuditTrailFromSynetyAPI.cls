global class scheduledAuditTrailFromSynetyAPI implements Schedulable
{
   global void execute(SchedulableContext SC) 
   {
        system.debug('Inside scheduledAuditTrailFromSynetyAPI execute');
        getAuditTrailData();
   }

    @future(callout=true)
    static void getAuditTrailData()
    {
        system.debug('Inside getAuditTrailData');
        String body = '';
        String fromdate = datetime.now().addDays(-1).Format('yyyy-MM-dd');
        String todate = datetime.now().Format('yyyy-MM-dd');
        system.debug('FromDate - ' + FromDate);
        system.debug('ToDate - ' + ToDate);        

        Http htp = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse(); 
        req = new HttpRequest();
        if(body != null && body.length()>0)
            req.setBody(body);
        req.setMethod('GET');
        req.setHeader('username', 'myuser');
        req.setHeader('Password', 'P@ssw0rd');
        req.setHeader('LicenseKey', '81A76B94-6ACD-4A70-BDC9-C4D9A549D356');
        req.setHeader('Origin', 'http://www.salesforce.com');
        req.setTimeout(120000);
        req.setHeader('Content-Length', '0');

        system.debug('Get All Synety Accounts');

        String endPoint = 'https://api-test.synety.com/Synety/Synety/GetAPIInfo?method=customer';
        //String endPoint = 'https://api-test.synety.com/Synety/Synety/AuditTrailCloudCall?from='+fromdate'&to='+todate'&login=mark.seemann@synety.com';
        
        system.debug('endPoint - ' + endPoint);
        req.setEndpoint(endPoint);
        system.debug('req - ' + req);
        res = htp.send(req);
        if(res.getStatusCode() != 200)
        {
            system.debug('API call is not successful.');
        }
        system.debug('res.getStatus - ' + res.getStatus());
        system.debug('res - ' + res);
        system.debug('res.getBody - ' + res.getBody());
    }
}