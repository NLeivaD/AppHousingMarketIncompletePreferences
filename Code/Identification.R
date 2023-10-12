################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# THIS SCRIPT DEVELOP A FUNCTION THAT TAKES A LIST OF TEXT AND INTERPRETS THEM
# AS PREFERENCES. THE LIST MUST CONTAIN N + 1 ELEMENTS, WHERE N IS THE NUMBER
# OF AGENTS. THE ELEMENTS IN THE LIST MUST BE
# (1) THE NUMBER OF AGENTS
# (2 to N) THE PREFERENCES INPUTED AS TEXT IN THE APP
Identification <- function(input){
  # DEFINE AN EMPTY LIST THAT WILL CONTAIN THE PREFERENCES
  Preferences <- list()
  # FOR EACH PREFERENCE IN THE INPUT LIST SPLIT THE CHARACTERS AS COMMAS AND
  # PARENTHESIS. KEEP JUST NUMBERS
  for (i in 1:input$NumAgents) {
    # EXTRACT THE TEXT FROM THE LIST
    succ_i <- input[[paste0("succ_",i)]]
    # ERASE PARENTHESIS BETWEEN ORDERED PAIRS
    succ_i <- unlist(strsplit(succ_i, "\\)\\,\\("))
    # EXTRACT FIRST OPEN PARENTHESIS AND LAST CLOSE PARENTHESIS
    succ_i <- strsplit(succ_i, "\\(|\\)")
    # IF THERE IS DEFINED PREFERENCES, IDENTIFY THEM
    if(length(succ_i) > 0){
      # FIRSST ELEMENT HAS AN EMPTY CHARACTER "" SO MUST BE ERASED
      succ_i[[1]] <- succ_i[[1]][2]
      # FOR EACH TEXT OF THE LIST, THAT ARE TWO NUMBERS TRANSFORM TO NUMERIC
      for (n in 1:length(succ_i)) {
        succ_i[[n]] <- unlist(lapply(strsplit(succ_i[[n]], ","), as.numeric))
      }
    }
    # STORE THIS LIST OF NUMERIC PREFERENCES IN THE PRINCIPAL LIST
    Preferences[[paste0("succ_", i)]] <- succ_i
    rm(succ_i)
  }
  rm(i, n)
  return(Preferences)
}
