public class QuickBooksAuthenticationJSONParseService {
   public static void consumeObject(JSONParser parser) {
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	public class JSON2Apex {
		public String token_type {get;set;} 
		public Integer x_refresh_token_expires_in {get;set;} 
		public String refresh_token {get;set;} 
		public String access_token {get;set;} 
		public Integer expires_in {get;set;} 

		public JSON2Apex(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'token_type') {
							token_type = parser.getText();
						} else if (text == 'x_refresh_token_expires_in') {
							x_refresh_token_expires_in = parser.getIntegerValue();
						} else if (text == 'refresh_token') {
							refresh_token = parser.getText();
						} else if (text == 'access_token') {
							access_token = parser.getText();
						} else if (text == 'expires_in') {
							expires_in = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static JSON2Apex parse(String json) {
		return new JSON2Apex(System.JSON.createParser(json));
	}
}