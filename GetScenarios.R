################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# THIS SCRIPT DEVELOP A FUNCTION THAT TAKES A LIST OF DATA CONTAINING FOR EACH
# AGENT ITS PREFERENCES, IF THIS PREFERECES ARE COMPLETE, INCOMPLETE OR EMPTY,
# IF INCOMPLETE OR EMPTY THE STC RESULTS GIVING TRANSITIVE COMPLETIONS OF THE
# PREFERENCES AND THE NUMBER OF TRANSITIVE COMPLETIONS.
# THE IDEA IS TO GET AS OUTPUT A LIST CONTAINING:
# (I)  THE DIFFERENT COMBINATIONS OF THE PREFERENCES PROFILES OR COMPLETIONS
# (II) FOR EACH COMBINATION, THE PREFERENCE MATRIX THAT WILL BE THE INPUT TO THE
#      TOPTRADING FUNCTION AND GET THE CORE.
# FIRST IS DEFINED THE FUNCTION ALONG WITH ITS ARGUMENT
GetScenarios <- function(Data){
  # NOW DEFINE THE EMPTY LIST THAT WILL CONTAIN THE RESULTS
  Scenarios <- list()
  # NOW BUILD THE DIFFERENT SCENARIOS GETTING THE NAMES OF THE PREFERENCES
  # PROFILES OR COMPLETIONS FOR EACH AGENT, START WITH AN EMPTY LIST
  Names <- list()
  # FOR EACH AGENT
  for (a in 1:Data$NumAgents) {
    # IF IS COMPLETE THE PREFERENCE
    if(Data[[paste0("Agent_", a)]]$Status == "Complete"){
      # GET THE PREFERENCE PROFILE
      Names[[paste0("Agent_", a)]] <- paste0("succ_",a)
      # IF ISN'T COMPLETE
    } else {
      # GET THE NUMBER OF COMPLETIOS
      NumComp <- Data[[paste0("Agent_", a)]]$NumComp
      # BUILD AND STORE THE NAMES
      Names[[paste0("Agent_", a)]] <- paste0("succ_", a, "_", 1:NumComp)
      rm(NumComp)
    }
  }
  rm(a)
  # NOW WITH THE NAMES BUILT, GET ALL THE POSSIBLE COMBINATIONS
  Combinations <- expand.grid(Names)
  rm(Names)
  # WITH THE COMBINATIOS DEFINED, EACH ROW IN COMBINATIONS REPRESENTS A 
  # DIFFERENT SCENARIO, SO BUILT EACH SCENARIO
  for (s in 1:nrow(Combinations)) {
    # START WITH AN EMPTY LIST FOR THAT SCENARIO
    Scenarios[[paste0("Scenario_", s)]] <- list()
    # NOW LOOK FOR EACH PREFERENCE OR COMPLETION FOR EACH AGENT
    for (p in 1:ncol(Combinations)) {
      # GET THE NAME TO LOOK FOR
      Name <- as.character(Combinations[s,p])
      # GET THE NAME FROM AGENT'S INFORMATION AND APPEND TO THE LIST
      Scenarios[[paste0("Scenario_", s)]][[Name]] <- Data[[paste0("Agent_", p)]][[Name]]
    }
    rm(p, Name)
    # WITH THE PREFERENCES PROFILES/COMPLETIONS NOW CAN BE OBTAINED THE PREFERENCE MATRIX
    Scenarios[[paste0("Scenario_", s)]][["PrefMatrix"]] <- PreferenceMatrix(Scenarios[[paste0("Scenario_", s)]])
  }
  rm(s)
  return(Scenarios)
}
