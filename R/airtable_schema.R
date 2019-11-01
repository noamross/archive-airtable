library(webdriver)
library(jsonlite)

schema_js_code <- "
var myapp = {
	id:window.application.id,
	name:window.application.name,
	tables:[]
};

window.application.tables.map(function(table){

	var mytable = {
			id:table.id,
			isEmpty:table.isEmpty,
			name:table.name,
			nameForUrl:table.nameForUrl,
			primaryColumnName:table.primaryColumnName,
			columns:[]
	};

	  table.columns.map(function(column){
	  		var mycolumn = {
	  		id:column.id,
	  		name:column.name,
	  		type:column.type,
	  		typeOptions:column.typeOptions
	  	};
	  mytable.columns.push(mycolumn);
	})

	myapp.tables.push(mytable);

})

var schema_json = JSON.stringify(myapp);
return schema_json
"

get_airtable_schema <- function(appid,
                                email = Sys.getenv("AIRTABLE_LOGIN_EMAIL"),
                                pwd = Sys.getenv("AIRTABLE_LOGIN_PWD")) {
  pjs <- run_phantomjs()
  ses <- Session$new(port = pjs$port)
  ses$go(paste0("https://airtable.com/", appid, "/api/docs"))
  email_field <- ses$findElement(xpath = '//*[@id="sign-in-form-fields-root"]/div/label[1]/input')
  pwd_field <- ses$findElement(xpath = '//*[@id="sign-in-form-fields-root"]/div/label[2]/input')
  login_btn <- ses$findElement(xpath = '//*[@id="sign-in-form-fields-root"]/div/label[3]/input')
  email_field$sendKeys(email)
  pwd_field$sendKeys(pwd)
  login_btn$click()
  schema_json <- ses$executeScript(schema_js_code)
  schema <- jsonlite::fromJSON(schema_json, simplifyVector = FALSE)
  return(schema)
}

airtable_names <- function(schema) {
  map_chr(schema$tables, "name")
}

schema_table <- function(schema) {
  map_dfr(schema$tables, function(tab) {
    map_dfr(tab$columns, .f = function(col) {
      tibble(table = tab$name,
             column = col$name,
             type = col$type,
             type_info = case_when(
               col$type == "select" ~ paste0(map_chr(col$typeOptions$choices,"name"),
                                        collapse = ","),
               col$type == "formula" ~ col$typeOptions$formulaTextParsed,
               TRUE ~ "!"
             )
      )
    })
  })
}

