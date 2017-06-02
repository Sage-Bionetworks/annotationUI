#-------------------------------------------------------------
# Server function assembles input and outputs from ui object 
# and renders *in from and *out of a web page
# inputs can be toggled by user 
# outputs are information displays 
#-------------------------------------------------------------
server <- function(input, output, session) {
  # use the same name from output functions in ui
  # render function creates the type of output
  dataOut <- reactive({
    if (input$cat > 0) {
      dat <- dat[which(dat$project %in% input$cat),]
    }
    else{
      dat
    }
    
    inFile <- input$userAnnot
    
    if (is.null(inFile)) {
      return(dat)
    }
    
    # Use fread function to catch user defined formats, handle large files, and execute correct errors as needed
    user.dat <-  fread(inFile$datapath, encoding = "UTF-8", fill = TRUE, blank.lines.skip = TRUE, na.strings = c("",NA,"NULL") , data.table = FALSE)
    
    ## if dat is redcap dictionary: 
    #------------------------------
    
    # remove empty rows 
    user.dat <- user.dat[which(!user.dat == "" | user.dat == NA),]

    # extract complete cases of values or keys     
    value <- user.dat[["value"]][!is.na(user.dat[["value"]])]
    key.values <- user.dat[["key"]][!is.na(user.dat[["value"]])]
    many.values <- as.data.frame(cbind(key.values, value))
    
    # seperate values by , and make one-to-one relation between key-values
    values <- strsplit(many.values$value, "[,]")
    
    # unnest or normalize each value to key relation 
    normalized <- lapply(seq_along(many.values$key.values), function(i){
      df <- lapply(seq_along(values[[i]]), function(j){
        cbind(many.values$key.values[[i]], values[[i]][[j]])
      })
      df <- do.call(rbind, df)
      return(df)
    })
    
    normalized <- as.data.frame(do.call(rbind, normalized), stringsAsFactors = F)
    names(normalized) <- c("key", "value")
    
    # extract keys without pre-defined values (ex. patientID where it could be left as NA due to privacy or timing)
    only.keys <- as.data.frame(amy.dict[[1]][!is.na(amy.dict[[1]])][which(!amy.dict[[1]][!is.na(amy.dict[[1]])] %in% unique(normalized$key))], stringsAsFactors = F)
    names(only.keys) <- "key"
    only.keys[,"value"] <- NA
    
    # combine lone keys with normalized data
    final.dat <- rbind(only.keys, normalized)

    #TODO: pass in projects name
    final.dat[ ,"project"] <- "DHArMA"

    #TODO: pass in cols don't exist 
    final.dat[,c("description", "columnType", "maximumSize", "valueDescription", "valueSource")] <- NA

    user.dat <- final.dat
    
    # Standardized user input to have the same colnames: this line needs to be removed
    standard.cols <- c("key", "description", "columnType", "maximumSize", "value", "valueDescription", "valueSource", "project")
    
    if (!colnames(user.dat) %in% standard.cols){
      #TODO: output error to ui
      print("error")
    }
  
    dat <- rbind(dat, user.dat)
    dat 
  })

  output$annotationTable <- shiny::renderDataTable({
    
    dataOut() 
  
  },options = list(lengthMenu = c(5, 10, 50, 100, 1000), pageLength = 5))

  observe({
    x <- input$cat
    
    if (is.null(x)) {
      x <- character(0)
    }
    
    updateCheckboxGroupInput(session, "",
                             label = paste("", length(x)),
                             choices = x,
                             selected = x
    )
  })
  
  
  output$downloadSchema <- downloadHandler(
    filename <- function() {'annotations_manifest.xlsx'},
    content <- function(file) {
      
      user.dat <- dataOut()
      
      first.cols <- c("synapseId", "fileName")
      user.cols <- unique(user.dat[["key"]])
      
      columns <- append(c("synapseId", "fileName"), user.cols)
      schema <- data.frame(matrix(ncol = length(columns), nrow = 0))
      colnames(schema) <- columns
      key.description <- user.dat[,c("key", "description", "columnType", "project")]
      value.description <- user.dat[,c("key", "value", "valueDescription", "valueSource", "project")]
      
      sheets <- list(manifest = schema , keyDescription = key.description, keyValueDescription = value.description)
      openxlsx::write.xlsx(sheets, file)
    }
  )
  
  # Automatically stop the app session after closing the browser tab
  session$onSessionEnded(stopApp)
}