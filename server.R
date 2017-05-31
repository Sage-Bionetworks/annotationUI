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
    
    # remove empty rows 
    user.dat <- user.dat[which(!user.dat == "" | is.na(user.dat)),]
    
    # Standardized user input to have the same colnames: this line needs to be removed
    colnames(user.dat) <- c("key", "description", "columnType", "maximumSize", "value", "value_description", "value_source", "project")

    dat <- rbind(dat, user.dat)
    dat 
  })

  output$annotationTable <- shiny::renderDataTable({
    
    dataOut() 
  
  },options = list(lengthMenu = c(5, 10, 50, 100), pageLength = 10))

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
      value.description <- user.dat[,c("key", "value", "value_description", "value_source", "project")]
      
      sheets <- list(manifest = schema , key.description = key.description, keyvalue.description = value.description)
      openxlsx::write.xlsx(sheets, file)
    }
  )
  
  # Automatically stop the app session after closing the browser tab
  session$onSessionEnded(stopApp)
}