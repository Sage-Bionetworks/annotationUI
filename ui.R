# UI component  -----------------------------------------------
# UI component generates the HTML 
# HTML: hypertext markup language 
# •	Hypertext: Interactive text or overcoming the constrains of text. 
# •	Markup: Is marking up different sections of a page as lists, links, 
#   or even specifying its attributes or changing font size
# HTML language is written by “tags” while its content is 
# preserved inside the opening and closing tags.  
# Different web browsers (ex. Firefox, Chrome,…) read .html files and 
# display it (idea is to be consistent and similar)
#-------------------------------------------------------------
shinyUI(fluidPage(theme = shinytheme("flatly"),
                  
                  titlePanel(paste0("Annotation UI ", release.version)),
                  
                  sidebarLayout(
                    
                    sidebarPanel(
                      checkboxGroupInput("cat", "Annotation Modules",
                                         choiceNames = categories,
                                         choiceValues = categories, 
                                         selected = categories), 
                      checkboxInput('allNone', 'All/None'),
                      tags$hr(),
                      p(strong("Upload Your Annotation's Module"), align = "left"), 
                      textInput("projectName", "Module Name"),
                      fileInput("userAnnot", "Module CSV File",
                                accept = c("csv", "comma-separated-values",".csv"))
                      
                    ),
                    
                    mainPanel(
                      tabsetPanel(
                        tabPanel("Table", DT::dataTableOutput('annotationTable'),
                                 downloadButton('downloadSchema', 'Download Manifest'),
                                 downloadButton('downloadJSON', 'Download JSON')
                        ), 
                        tabPanel("Key Description", DT::dataTableOutput('keyDescription')), 
                        tabPanel("Value Description", DT::dataTableOutput('valueDescription'))
                      )
                    )
                  )
))