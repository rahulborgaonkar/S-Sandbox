public class SalesCommissionPartnerInfoExtension 
{
    ApexPages.StandardController scp{get;set;}
    public static Opportunity prevopp{get;set;}
    public SalesCommissionPartnerInfoExtension(ApexPages.StandardController controller) 
    {
        scp = controller;
        prevopp = (Opportunity) scp.getrecord();
        system.debug('prevopp.Telesales_Partner_Commission_Flag__c - '  + prevopp.Telesales_Partner_Commission_Flag__c);
    }

    public void saveSalesCommissionPartner()
    {
        system.debug('Inside saveSalesCommissionPartner');
        Opportunity opp = (Opportunity) scp.getrecord();
        update opp;
    }

    public Pagereference cancelSalesCommissionPartner()
    {
        system.debug('Inside cancelSalesCommissionPartner');
        system.debug('prevopp - '  + prevopp);
        Opportunity newopp = (Opportunity) scp.getrecord();
        system.debug('newopp - '  + newopp);
        Pagereference cancelReturn = new Pagereference('/apex/SalesCommissionPartnerInfoPage?id='+newopp.id);
        cancelReturn.SetRedirect(true);
        return cancelReturn ;
    }

    public Pagereference calculateSalesCommission()
    {
        system.debug('Inside calculateSalesCommission');
        Opportunity curropp = (Opportunity) scp.getrecord();
        system.debug('curropp - '  + curropp);
        Set<String> oppProductList = new Set<String> ();
        List<OpportunityLineItem> curroli = [SELECT PricebookEntryId, PricebookEntry.name, Contract_Term__c, Contract_Term_Calc__c, Monthly_Fees_with_Discount__c, Purchase_Set_Up_Charges__c, License_Fee_Mth__c, Total_Annual_Value__c, Licenses__c, Description, Id, ListPrice, Monthly_Discount__c, Discount, UnitPrice, Monthly_Fees__c, OpportunityId, Set_Up__c, Payment_Term__c, Product_Type_New__c, Product_Type__c, Product_number_of_seats__c, Quantity, Set_Up_Disc__c, Set_Up_Discount_New__c, Set_Up_Discount_Percent__c, Set_Up_Discount__c, Set_Up_Fee__c, Total_Contract_Value_One_Year__c, Total_Initial_Fee__c, Total_Mth_Fee__c, TotalPrice, Total_Yearly_Fee__c, Total_number_of_seats__c FROM OpportunityLineItem where opportunityid = :curropp.id];
        system.debug('List<OpportunityLineItem> curroli - ' + curroli);

        for(OpportunityLineItem toli : curroli)
        {
            if(string.isnotblank(toli.PricebookEntry.name))
            {
                oppProductList.add(toli.PricebookEntry.name);
            }
        }

        if(oppProductList.size() > 0)
        {
            system.debug('Set<String> oppProductList - ' + oppProductList);
            Set<String> mapProductList = new Set<String> ();
            Set<String> mapEventList = new Set<String> ();
            List<Sales_Commission_Event_Product_Map__c> scepmList = [SELECT CurrencyIsoCode, Event__c, Product__c, Product__r.name, Id, Name FROM Sales_Commission_Event_Product_Map__c WHERE Product__r.name = :oppProductList];
            system.debug('List<Sales_Commission_Event_Product_Map__c> scepmList - ' + scepmList);
            for(Sales_Commission_Event_Product_Map__c tscepm : scepmList)
            {
                mapProductList.add(tscepm.Product__r.name);
            }

            system.debug('Set<String> oppProductList Size - ' + oppProductList.size());
            system.debug('Set<String> mapProductList Size - ' + mapProductList.size());
            
            if(oppProductList.size() != mapProductList.size())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Product listed on Opportunity not found in Product-Event Map'));
                return null;
            }

            for(Sales_Commission_Event_Product_Map__c tscepm : scepmList)
            {
                if(String.isNotBlank(tscepm.Event__c))
                {
                    mapEventList.add(tscepm.Event__c);
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Product Event Map contains Product Mapped to NULL Event'));
                    return null;
                }
            }

            Map<String, Sales_Commision_Internal_Partner__c> intPartners = new Map<String, Sales_Commision_Internal_Partner__c> ();
            Map<String, Account> extPartners = new Map<String, Account> ();

            if(curropp.Referral_Partner_Commission_Flag__c == null && curropp.CRM_Integrator_Partner_Commission_Flag__c == null && curropp.Telesales_Partner_Commission_Flag__c == null && curropp.Channel_Sales_Partner_Commission_Flag__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'All \'Commission Applicable?\' flags have \'--None--\' values, Unable to calculate Commission'));
                return null;
            }

            if(curropp.Telesales_Partner_Commission_Flag__c == 'Yes')
            {
                String partner = 'Telesales Partner';
                List<Sales_Commision_Internal_Partner__c> p = [SELECT CurrencyIsoCode, Email__c, Name, OwnerId, Phone__c, Id, Sales_Commission_Plan__c, Title__c FROM Sales_Commision_Internal_Partner__c where id = :curropp.Telesales_Partner__c LIMIT 1];

                if(p.size() == 1 && p[0].Sales_Commission_Plan__c != null)
                {
                    intPartners.put(partner, p[0]);
                    system.debug('Map<String, Sales_Commision_Internal_Partner__c> intPartners - ' + intPartners);
                }
                else
                {
                    String err = partner + ' ' + p[0].name + ' has NO Sales Commission plan attached';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err));
                    return null;
                }
            }

            if(curropp.Channel_Sales_Partner_Commission_Flag__c == 'Yes')
            {
                String partner = 'Channel Sales Partner';
                List<Sales_Commision_Internal_Partner__c> p = [SELECT CurrencyIsoCode, Email__c, Name, OwnerId, Phone__c, Id, Sales_Commission_Plan__c, Title__c FROM Sales_Commision_Internal_Partner__c where id = :curropp.Channel_Sales_Partner__c LIMIT 1];

                if(p.size() == 1 && p[0].Sales_Commission_Plan__c != null)
                {
                    intPartners.put(partner, p[0]);
                    List<Sales_Commission_Detail__c> scdSingle = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdMulti = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdAll = [SELECT Commissions_Types__c, CurrencyIsoCode, Event__c, Frequencies__c, Partner_Types__c, Id, Name, Sales_Commission_Plan__c, Selected_Record__c, SingleEvent__c, Sub_Event__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c WHERE Sales_Commission_Plan__c = :p[0].Sales_Commission_Plan__c and Partner_Types__c = :partner];
                    system.debug('Map<String, Sales_Commision_Internal_Partner__c> intPartners - ' + intPartners);
                    
                    for(Sales_Commission_Detail__c s : scdAll)
                    {
                        if(s.SingleEvent__c == true)
                        {
                            scdSingle.add(s);
                        }
                        else
                        {
                            scdMulti.add(s);
                        }
                    }
                    system.debug('List<Sales_Commission_Detail__c> scdSingle - ' + scdSingle);
                    system.debug('List<Sales_Commission_Detail__c> scdMulti - ' + scdMulti);
                    if(scdMulti.size() > 0)
                    {
                        List<Sales_Telesales_Detail__c> std = [SELECT Id, Maximum__c, Minimum__c, Percentage__c, Amount__c, Sales_Commission_Detail__c, Sales_Commission_Detail__r.name, Name, IsDeleted FROM Sales_Telesales_Detail__c WHERE Sales_Commission_Detail__c = :scdMulti];
                        system.debug('List<Sales_Telesales_Detail__c> std - ' + std);
                    }

                }
                else
                {
                    String err = partner + ' ' + p[0].name + ' has NO Sales Commission plan attached';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err));
                    return null;
                }
            }

            if(curropp.Referral_Partner_Commission_Flag__c == 'Yes')
            {
                String partner = 'Referral Partner';
                List<Account> p = [SELECT Id, Name, Phone, Type, Date_to_Book_Demo__c, NumberOfEmployees, No_of_CRM_Seats__c, Sales_Commission_Plan__c, Total_Licenses__c, Website FROM Account WHERE id = :curropp.Referral_Partner__c LIMIT 1];

                if(p.size() == 1 && p[0].Sales_Commission_Plan__c != null)
                {
                    extPartners.put(partner, p[0]);
                    List<Sales_Commission_Detail__c> scdSingle = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdMulti = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdAll = [SELECT Commissions_Types__c, CurrencyIsoCode, Event__c, Frequencies__c, Partner_Types__c, Id, Name, Sales_Commission_Plan__c, Selected_Record__c, SingleEvent__c, Sub_Event__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c WHERE Sales_Commission_Plan__c = :p[0].Sales_Commission_Plan__c and Partner_Types__c = :partner];
                    system.debug('Map<String, Account> extPartners - ' + extPartners);
                
                    for(Sales_Commission_Detail__c s : scdAll)
                    {
                        if(s.SingleEvent__c == true)
                        {
                            scdSingle.add(s);
                        }
                        else
                        {
                            scdMulti.add(s);
                        }
                    }
                    system.debug('List<Sales_Commission_Detail__c> scdSingle - ' + scdSingle);
                    system.debug('List<Sales_Commission_Detail__c> scdMulti - ' + scdMulti);
                    if(scdMulti.size() > 0)
                    {
                        List<Sales_Telesales_Detail__c> std = [SELECT Id, Maximum__c, Minimum__c, Percentage__c, Amount__c, Sales_Commission_Detail__c, Sales_Commission_Detail__r.name, Name, IsDeleted FROM Sales_Telesales_Detail__c WHERE Sales_Commission_Detail__c = :scdMulti];
                        system.debug('List<Sales_Telesales_Detail__c> std - ' + std);
                    }
                }
                else
                {
                    String err = partner + ' ' + p[0].name + ' has NO Sales Commission plan attached';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err));
                    return null;
                }
            }
            
            if(curropp.CRM_Integrator_Partner_Commission_Flag__c == 'Yes')
            {
                String partner = 'CRM Integrator Partner';
                List<Account> p = [SELECT Id, Name, Phone, Type, Date_to_Book_Demo__c, NumberOfEmployees, No_of_CRM_Seats__c, Sales_Commission_Plan__c, Total_Licenses__c, Website FROM Account WHERE id = :curropp.CRM_Integrator_Partner__c LIMIT 1];

                if(p.size() == 1 && p[0].Sales_Commission_Plan__c != null)
                {
                    extPartners.put(partner, p[0]);
                    List<Sales_Commission_Detail__c> scdSingle = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdMulti = new List<Sales_Commission_Detail__c>();
                    List<Sales_Commission_Detail__c> scdAll = [SELECT Commissions_Types__c, CurrencyIsoCode, Event__c, Frequencies__c, Partner_Types__c, Id, Name, Sales_Commission_Plan__c, Selected_Record__c, SingleEvent__c, Sub_Event__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c WHERE Sales_Commission_Plan__c = :p[0].Sales_Commission_Plan__c and Partner_Types__c = :partner];
                    system.debug('Map<String, Account> extPartners - ' + extPartners);
                    
                    for(Sales_Commission_Detail__c s : scdAll)
                    {
                        if(s.SingleEvent__c == true)
                        {
                            scdSingle.add(s);
                        }
                        else
                        {
                            scdMulti.add(s);
                        }
                    }
                    system.debug('List<Sales_Commission_Detail__c> scdSingle - ' + scdSingle);
                    system.debug('List<Sales_Commission_Detail__c> scdMulti - ' + scdMulti);
                    if(scdMulti.size() > 0)
                    {
                        List<Sales_Telesales_Detail__c> std = [SELECT Id, Maximum__c, Minimum__c, Percentage__c, Amount__c, Sales_Commission_Detail__c, Sales_Commission_Detail__r.name, Name, IsDeleted FROM Sales_Telesales_Detail__c WHERE Sales_Commission_Detail__c = :scdMulti];
                        system.debug('List<Sales_Telesales_Detail__c> std - ' + std);
                    }
                }
                else
                {
                    String err = partner  + ' ' + p[0].name + ' has NO Sales Commission plan attached';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err));
                    return null;
                }
            }

        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Product Name not found in PricebookEntry Table'));
            return null;
        }

        Pagereference calculateReturn = new Pagereference('/apex/SalesCommissionPartnerInfoPage?id='+curropp.id);
        calculateReturn.SetRedirect(true);
        return calculateReturn ;
    }

}