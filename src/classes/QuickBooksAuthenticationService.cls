public class QuickBooksAuthenticationService {

    public static string authorization_Code{get; set;}
    
    public QuickBooksAuthenticationService(){
    
       
    }

    public static pageReference getAuthorizationToken(){
       
       QuickBooks_Info__c qbInfo = QuickBooks_Info__c.getValues('Authorization Details');
       
       String authorization_endpoint = qbInfo.Authorization_Endpoint__c;
       String scope = qbInfo.Scope__c;
       String redirect_uri = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickBooksAuthentication';
       String client_Id = qbInfo.client_Id__c;
       string state = qbInfo.State__c;
       String final_EndPoint = authorization_endpoint+'?client_id='+ client_Id +
                                                      '&response_type=code' +
                                                      '&scope='+ scope +
                                                      '&state=' + state + 
                                                      '&redirect_uri='+redirect_URI;
 
       PageReference pageRef = new PageReference(final_EndPoint);
       authorization_Code = ApexPages.currentPage().getParameters().get('code');
       system.debug('====Authorization code====='+ authorization_Code);
       
       return pageRef;
    
    
    }
    
    public PageReference getAccessToken() {
    	system.debug('==Method is entered==');
    	QuickBooks_Info__c qbInfo = QuickBooks_Info__c.getValues('Authorization Details');
    	String final_EndPoint = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickBooksAuthentication';
        string state = apexpages.currentpage().getparameters().get('state');
        String client_Id = qbInfo.client_Id__c;
        String client_Secret = qbInfo.client_Secret__c;
        string authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(client_Id+':'+client_Secret));
        String redirect_uri = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickBooksAuthentication';
        authorization_Code = apexpages.currentpage().getparameters().get('code');
        String error = apexpages.currentpage().getparameters().get('error');
        String body = 'grant_type=authorization_code&' + 'code='+ authorization_Code + '&redirect_uri=' + redirect_uri;
        
        try{
	        if (state == 'Anti_Forgery' && String.isBlank(error)){
	        	   system.debug('==If is entering===');
	                http h = new http();
	        	    httpRequest hReq = new httpRequest();
	        	    hReq.setMethod('POST');
	        	    hReq.setEndpoint('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer');
	        	    hReq.setHeader('Accept', 'application/json');
	        	    hReq.setHeader('Authorization', authHeader);
	        	    hReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
	        	    hReq.setBody(body);
	        	    
	        	    httpResponse hRes = h.send(hReq);
	        	    System.debug('===Response===' + hRes.getBody());
	        	    System.debug('===Status code==='+hRes.getStatusCode());
	        	    if (hRes.getStatusCode() == 200){
			        	    QuickBooksAuthenticationJSONParseService.JSON2Apex j2A = QuickBooksAuthenticationJSONParseService.parse(hRes.getBody());
			        	    QuickBooks_Detail__c qbD = [SELECT id, Name, Refresh_Token__c, Refresh_Token_Expires_After__c, Access_Token__c, Access_Token_Expires_After__c FROM QuickBooks_Detail__c WHERE id='a0U0G00000xCyaW'];
			        	    qbD.Name = 'Token Details';
			        	    qbD.Refresh_Token__c = j2A.refresh_token; 
			        	    qbD.Refresh_Token_Expires_After__c = j2A.x_refresh_token_expires_in; 
			        	    qbD.Access_Token__c = j2A.access_token; 
			        	    qbD.Access_Token_Expires_After__c = j2A.expires_in;
			        	    upsert qbD;
	        	    } 
	        } 
	        	
	        } Catch(Exception e){
	        	  
                  ApexPages.addMessages(e); 
            }   
        PageReference pageRef = new PageReference(final_EndPoint);
        return pageRef;
        
    }
    
    public void getNewRefreshToken(){
    	QuickBooks_Info__c qbInfo = QuickBooks_Info__c.getValues('Authorization Details');
    	String client_Id = qbInfo.client_Id__c;
        String client_Secret = qbInfo.client_Secret__c;
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(client_Id+':'+client_Secret));
        String rTokenOld;
        QuickBooks_Detail__c qbR = [SELECT id, Name, Refresh_Token__c, Refresh_Token_Expires_After__c, Access_Token__c, Access_Token_Expires_After__c FROM QuickBooks_Detail__c WHERE id='a0U0G00000xCyaW'];
        if (!String.isBlank(qbR.Refresh_Token__c)){
            rTokenOld = qbR.Refresh_Token__c;
        }
        String body = 'grant_type=refresh_token&refresh_token='+rTokenOld;
    	system.debug('===Body==='+body);
    	try{
    	     if (!String.isEmpty(rTokenOld)){
    	        http h = new http();
        	    httpRequest hReq = new httpRequest();
        	    hReq.setMethod('POST');
        	    hReq.setEndpoint('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer');
        	    hReq.setHeader('Accept', 'application/json');
        	    hReq.setHeader('Authorization', authHeader);
        	    hReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        	    hReq.setBody(body);
        	    
        	    httpResponse hRes = h.send(hReq);
                System.debug('===Response===' + hRes.getBody());
        	    System.debug('===Status code==='+hRes.getStatusCode());
        	    if (hRes.getStatusCode() == 200){
		        	    QuickBooksAuthenticationJSONParseService.JSON2Apex j2AR = QuickBooksAuthenticationJSONParseService.parse(hRes.getBody());
		        	    qbR.Name = 'Token Details';
		        	    qbR.Refresh_Token__c = j2AR.refresh_token; 
		        	    qbR.Refresh_Token_Expires_After__c = j2AR.x_refresh_token_expires_in; 
		        	    qbR.Access_Token__c = j2AR.access_token; 
		        	    qbR.Access_Token_Expires_After__c = j2AR.expires_in;
		        	    upsert qbR;
        	    }
    	     }
    	} catch (exception e){
    		
    	     ApexPages.addMessages(e);	
    	}
    	 
    }
    
}