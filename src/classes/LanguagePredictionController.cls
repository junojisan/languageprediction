public with sharing class LanguagePredictionController {

	public Case cs {get; set;}
	public String request {get; set;}
	public String response {get; set;}

	private static final String END_POINT = 'https://predictionherokuapp.herokuapp.com/predict';

	/**
	 * コンストラクタ
	 * @param stdController
	 * @return LanguagePredictionController
	 */
    public LanguagePredictionController(ApexPages.StandardController stdController) {
        this.cs = (Case)stdController.getRecord();
		cs = [Select Id, CaseNumber, Subject, Description, Language__c From Case Where Id = :cs.Id];
    }

	/**
	 * 言語を予測ボタンのアクションハンドラです
	 * @param
	 * @return PageReference
	 */
	public PageReference doPredict(){
		PageReference pref = null;
		cs.Language__c = getPredictLanguage(cs.Description);
		update cs;
		return pref;
	}

	/**
	 * 言語を予測ボタンのアクションハンドラです
	 * @param text 言語の予測を行う文字列
	 * @return String 予測結果の言語
	 */
	private String getPredictLanguage(String text){
		String language = null;

		JSONGenerator generator = JSON.createGenerator(true);
		generator.writeStartObject();
		generator.writeStringField('text', text);
		generator.writeEndObject();
		request = generator.getAsString();

		HttpRequest req = new HttpRequest();
		req.setHeader('Content-type', 'application/json');
		req.setMethod('POST');
		req.setEndPoint(END_POINT);
		req.setBody(request);
		req.setTimeout(60000);

		try{
			Http http = new Http();
			HttpResponse res = http.send(req);
			response = res.getBody();
			JSONParser parser = JSON.createParser(res.getBody());
			while(parser.nextToken() != null){
				if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'label'){
					parser.nextToken();
					language = parser.getText();
				}
			}
		}catch(Exception e){
			System.debug(LoggingLevel.ERROR, e);
		}

		return language;
	}
}
