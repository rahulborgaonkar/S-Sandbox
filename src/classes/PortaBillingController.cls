public class PortaBillingController
{
    private final ApexPages.StandardController theController;
    
    public PortaBillingController(ApexPages.StandardController stdController) 
    {
        system.debug('In PortaBillingController Constructor');
        theController = stdController;    
    }

    // Code we will invoke on page load.
    public PageReference autoRun() 
    {
        system.debug('In autoRun');
        EmailTemplate cc_template = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate where Name = 'Confirmation of Credit Card Payment' LIMIT 1];
        //system.debug('cc_template - ' + cc_template);

        List<Document> doc_l = [SELECT Body, BodyLength, Id, Name, Type, ContentType FROM Document where Name = 'Test Invoice' limit 1];
        system.debug('doc_l - ' + doc_l);
        doc_l[0].name = doc_l[0].name + '.pdf';
        system.debug('doc_l - ' + doc_l[0].name);
        system.debug('doc_l - ' + doc_l[0].body);

        list<Messaging.EmailFileAttachment> eftlist = new list<Messaging.EmailFileAttachment>();

        if(doc_l.size() == 1)
        {
            Messaging.EmailFileAttachment eft1 = new Messaging.EmailFileAttachment();
            eft1.setContentType(doc_l[0].ContentType);
            eft1.setFileName(doc_l[0].Name);
            eft1.Body = doc_l[0].Body;
            eftlist.add(eft1);
        }
        system.debug('eftlist - ' + eftlist);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {'rahul.borgaonkar@synety.com'};
        mail.setToAddresses(toAddresses);

        //String[] BccAddresses = new String[] {'portb@2cb3xr1k10db4oqdmu17d823qnzhne16ellh56eb0jkmk7v0wy.z-p99wmaa.cs11.apex.sandbox.salesforce.com'};
        String[] BccAddresses = new String[] {'portb@y-2ptv1uz4kll6crebsot3qme8h3v66qeu7jzmtfcfegzd2yaz4j.g-glbmmau.na11.apex.salesforce.com'};
        mail.setBccAddresses(BccAddresses);

        mail.setSubject(cc_template.subject);
        mail.setPlainTextBody(cc_template.body);
        mail.setFileAttachments(eftlist);
        system.debug('Mail - ' + mail);

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}, true);
        system.debug('Messaging.SendEmailResult - ' + results);
        system.debug('Result - ' + results[0]);

        return theController.view().setRedirect(true);
    }
}