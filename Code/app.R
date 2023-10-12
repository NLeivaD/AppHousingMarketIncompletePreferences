################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# THIS SCRIPT DEVELOP A SHINY APP THAT IDENTIFY THE CORE SET AND STRONG CORE SET
# DEFINED AS IN GUAMAN, E. AND TORRES-MARTINEZ, J. (2023) "ON HOUSING MARKETS
# WITH INDECISIVE AGENTS".
# PROVIDES A USER INTERFACE WHERE THE USER WILL HAVE ONE TAB SHOWING SOME
# INFORMATION AND USING INSTRUCTIONS FOR THE APP AND ANOTHER TAB WHERE THE USER
# CAN MAKE USE OF THE APP TO FIND THE CORE SET AND THE STRONG CORE SET.

# PACKAGES TO USE
library(shiny) # FOR THE APP
library(matchingR) # FOR TOP TRADING CYCLES ALGORITHM

# SOME FUNCTIONS TO NOT OVERCHARGE FROM CODE THIS APP
source("Identification.R") # TO READ APP'S INPUT
source("CheckPreferences.R") # TO IDENTIFY COMPLETENESS OF PREFERENCES
source("CheckTransitivity.R") # USED IN SC TO CHECK TRANSITIVITY
source("SC.R") # APPLY THE SEQUENTIAL COMPLETION ALGORITHM
source("GetScenarios.R") # TO OBTAIN THE DIFFERENT SCENARIOS GIVEN FROM SC
source("PreferenceMatrix.R") # TO IDENTIFY THE PREFERENCE MATRIX GIVEN PREFERENCES
source("GetCore.R") # TO APPLY TTC TO EACH SCENARIO AND GET THE CORE
source("GetStrongCore.R") # IDENTIFIY WHICH ALLOCATION IN THE CORE IS IN THE STRONG CORE


# DEFINE UI FOR THE APP AS A FLUID PAGE
ui <- fluidPage(
  titlePanel('Shapley-Scarf housing markets with indecisive agents'),
  # INCLUDE FOR LATEX MATH INPUT
  tags$head(
    tags$link(rel="stylesheet", 
              href="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/katex.min.css", 
              integrity="sha384-dbVIfZGuN1Yq7/1Ocstc1lUEm+AT+/rCkibIcC/OmWo5f0EA48Vf8CytHzGrSwbQ",
              crossorigin="anonymous"),
    HTML('<script defer src="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/katex.min.js" integrity="sha384-2BKqo+exmr9su6dir+qCw08N2ZKRucY4PrGQPPWU1A7FtlCGjmEGFqXCv5nyM5Ij" crossorigin="anonymous"></script>'),
    HTML('<script defer src="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous"></script>'),
    HTML('
    <script>
      document.addEventListener("DOMContentLoaded", function(){
        renderMathInElement(document.body, {
          delimiters: [{left: "$", right: "$", display: false}]
        });
      })
    </script>')
  ),
  # SIDE BAR 
  sidebarLayout(
    sidebarPanel(
      p("This app computes the core and the strong core of a housing market with incomplete preferences."),
      numericInput("NumAgents", # NAME
                   "Number of Agents", # TEXT DISPLAY
                   value = 4, min = 3, max = 7), # DEFAULT AND MIN VALUES
      p('Report only the alternatives that agents are able to compare. Use the format $(i,j)$ to indicate that an agent strictly prefers the house $h_i$ to the house $h_j$.'),
      uiOutput("sliders"), # RENDER AS MUCH SLIDES AS WERE DEFINED
      actionButton("findbutton", # NAME
                   "Find the Core and the Strong Core") # TEXT DISPLAY
    ),
    mainPanel(
      uiOutput("core"))),
  # FOOTER
  tags$footer(HTML(paste0('<footer><small><div>The core and the strong core are studied in the paper <a href="https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4461572">On housing markets with indecisive agents</a> by Emilio Guamán and Juan Pablo Torres-Martínez.</div>',
                          '<div>This app relies on Jan Tilly and Nick Janetos’s ',
                          '<a href= "https://www.rdocumentation.org/packages/matchingR/versions/1.3.3">matchingR</a> ',
                          'package to implement part of the computations.</div>',
                          '<div>&copy; Developed by <a href= "https://github.com/NLeivaD">Nicolás Leiva Díaz</a>.</div></small></footer>')), 
              align="left", 
              style="position:absolute; bottom:0; width:100%; height:50px; color: #000000; padding: 0px; background-color: transparent; z-index: 1000;")
)

# DEFINE THE SERVER, WHAT IS GOING BACKEND
server <- function(input, output) {
  
  # DEFINE NUMBER OF TEXT INPUTS DEPENDING OF NUMBER OF AGENT
  output$sliders <- renderUI({
    NumAgents <- as.integer(input$NumAgents)
    # START WITH THE EXAMPLE 1 OF THE PAPER
    if(NumAgents == 4){
      lapply(1:NumAgents, function(i){
        if(i == 1){
          textInput(paste0("succ_", i), paste0("Agent ", i),
                    value = "(2,3),(2,1),(3,1),(4,3),(4,1)")
        } else if(i == 2){
          textInput(paste0("succ_", i), paste0("Agent ", i),
                    value = "(1,2),(1,3),(1,4),(2,3),(2,4),(3,4)")
        } else if(i == 3){
          textInput(paste0("succ_", i), paste0("Agent ", i),
                    value = "(1,4),(1,3),(1,2),(4,3),(4,2),(3,2)")
        } else{
          textInput(paste0("succ_", i), paste0("Agent ", i),
                    value = "(2,4),(2,1),(4,1),(2,3),(3,1)")
        }
      })
      } else {
        # WHEN CHANGE SHOW NOTHING
        lapply(1:NumAgents, function(i){
          textInput(paste0("succ_", i), paste0("Agent ", i),
                    value = "")
          })
    }
  })
  
  # DEFINE THE ACTION THAT WILL BE DONE WHEN THE USER PRESS THE BUTTON
  observeEvent(input$findbutton, {
    
    # CREATE THE PROGRESS BAR
    withProgress(message = "Process Stage:", value = 0, {
    
    # OBTAIN PREFERENCES AS LIST OF NUMERIC ELEMENTS FROM THE TEXT INPUTS
    incProgress(amount = 1/6, detail = "Reading Preferences")
    Preferences <- Identification(input)
    
    # CREATE A LIST THAT WILL CONTAIN A LIST FOR EACH AGENT CONTAINING:
    ## (I)   AGENT NUMBER
    ## (II)  PREFERENCES
    ## (III) STATUS. ONE FROM: COMPLETE, INCOMPLETE OR EMPTY
    ## (IV)  INCOMPARABLE HOUSES, IF APPLY ALONG WITH THE POSSIBLE PREFERENCES
    ##       FOR THAT INCOMPARABLE HOUSES
    incProgress(amount = 1/6, detail = "Checking Preferences Completeness")
    Data <- CheckPreferences(Preferences, input$NumAgents)
    
    # NOW APPLY SEQUENTIAL AND TRANSITIVE COMPLETATION ALGORITHM IN ORDER TO
    # GET DIFFERENT PREFERENCES PROFILES FOR EACH AGENT
    incProgress(amount = 1/6, detail = "Applying SC Algorithm")
    Data <- SC(Data)
    
    # NOW THAT HAVE THE SC RESULTS CAN BE DEFINED THE DIFFERENT SCENARIOS OF
    # EACH WITH THE DIFFERENT COMPLETIONS OF EACH PREFERENCE
    incProgress(amount = 1/6, detail = "Computing SC Combinations")
    Scenarios <- GetScenarios(Data)
    
    # WITH THE DIFFERENT SCENARIOS AND ITS RESPECTIVE PREFERENCE MATRIX CAN BE
    # OBTAINED THE CORE BY APPLYING TOP TRADING CYCLES ALGORITHM TO EACH 
    # SCENARIO
    incProgress(amount = 1/6, detail = "Finding Core")
    Core <- GetCore(Scenarios)
    
    # NOW THAT THE CORE IS DEFINED, PRINT A MESSAGE SHOWING THE CORE. FIRST
    # IDENTIFY IF THERE ARE ONLY COMPLETE PREFERENCES, DEFINE A VECTOR THAT WILL
    # STORE 1 IF A PREFERENCE IS COMPLETE AND 0 IF NOT FOR EACH AGENT
    Completes <- vector()
    # CHECK FOR EACH AGENT
    for (a in 1:input$NumAgents) {
      # GET THE STATUS OF COMPLETENESS
      AgentStatus <- Data[[paste0("Agent_", a)]]$Status
      # APPEND 1 TO COMPLETES IF IS COMPLETE AND 0 IF NOT
      Completes <- append(Completes,
                          ifelse(AgentStatus == "Complete", 1, 0))
    }
    rm(a, AgentStatus)
    # CHECK IF THE NUMBER OF COMPLETES (SUM OF COMPLETES) IS EQUAL TO THE NUMBER
    # OF AGENTS
    if(sum(Completes) == input$NumAgents){
      # IF ALL ARE COMPLETE PRINT THE NEXT MESSAGE
      coremessage <- paste0("<b>The core and the strong core coincide and are given by:</b>")
      # IF NOT ALL ARE COMPLETE
    } else {
      # PRINT THE NEXT MESSAGE
      coremessage <- paste0("<b>The core is characterized by the following allocations:</b>")
    }
    # NOW FOR EACH MATCHING IN THE CORE
    for (i in 1:length(Core)) {
      # GET THE MATCHING
      matching <- Core[[i]]
      # DEFINE THE MESSAGE SHOWING THE MATCHING
      mess <- paste0("[", paste0("(", matching$Agent, ",h", 
                                       matching$House, ")", collapse = ","), "]")
      # ADD THE MESSAGE OF THE MATCHING TO THE MESSAGE OF THE CORE
      coremessage <- c(coremessage, mess)
    }
    rm(i, mess, matching)
    # NOW IF THERE IS INCOMPLETE PREFERENCES THE STRONG CORE MUST BE FOUND
    if(sum(Completes) < input$NumAgents){
      incProgress(amount = 1/6, detail = "Computing Strong Core")
      # GET THE STRONG CORE
      StrongCore <- GetStrongCore(Core, Data)
      # CHECK IF THERE ARE ELEMENTS IN THE STRONG CORE, IF THERE ARE NOT
      if(length(StrongCore) == 0){
        # ADD THE MESSAGE SHOWING THE STRONG CORE IS EMPTY 
        coremessage <- c(coremessage, paste0("The strong core is an empty set."))
        # IF THERE ARE ELEMENTS IN THE STRONG CORE
      } else{
        # ADD THE MESSAGE SHOWING THERE IS A STRONG CORE 
        coremessage <- c(coremessage, paste0("<b>The strong core is given by</b>"))
        # NOW FOR EACH MATCHING IN THE STRONG CORE
        for (i in 1:length(StrongCore)) {
          # GET THE MATCHING
          matching <- StrongCore[[i]]
          # DEFINE THE MESSAGE SHOWING THE MATCHING
          mess <- paste0("[", paste0("(", matching$Agent, ",h", 
                                           matching$House, ")", collapse = ","), "]")
          # ADD THE MESSAGE OF THE MATCHING TO THE MESSAGE OF THE CORE
          coremessage <- c(coremessage, mess)
        }
        rm(i, mess, matching)
      }
    }
    })
    output$core <- renderUI({
      HTML(paste0(coremessage, collapse = "<br>"))
      })
      
    
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
