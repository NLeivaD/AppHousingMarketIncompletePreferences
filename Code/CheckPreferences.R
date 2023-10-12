################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# THIS SCRIPT DEVELOP A FUNCTION THAT TAKES A LIST OF PREFERENCES, AND FOR EACH
# ONE OF THE PREFERENCES DEFINE:
#   (I)   AGENT NUMBER
#   (II)  PREFERENCES
#   (III) STATUS. ONE FROM: COMPLETE, INCOMPLETE OR EMPTY
#   (IV)  INCOMPARABLE HOUSES, IF APPLY
# FIRST DEFINE THE FUNCTION WITH TWO INPUTS:
#   (1) THE PREFERENCES INPUTED IN THE APP
#   (2) THE NUMBER OF AGENTS
CheckPreferences <- function(Preferences, NumAgents){
  # DEFINE AN EMPTY LIST THAT WILL STORE ALL THE INFORMATION
  Data <- list()
  # DEFINE THE NUMBER OF AGENTS
  Data[["NumAgents"]] <- NumAgents
  # DEFINE THE NUMBER OF PREFERENCES DEFINED IF THE AGENT HAS COMPLETE ONES
  NumPreferences <- sum(1:(NumAgents - 1))
  # FOR EACH PREFERENCE
  for (i in 1:length(Preferences)) {
    # DEFINE AN EMPTY LIST
    Agent <- list()
    # DEFINE THE AGENT NUMBER
    Agent[["Agent Number"]] <- i
    # EXTRACT THE PREFERENCE
    succ_i <- Preferences[[i]]
    # ASSIGN THE PREFERENCES
    Agent[[paste0("succ_", i)]] <- succ_i
    # DEFINE THE STATUS
    Agent[["Status"]] <- ifelse(length(succ_i) == 0, "Empty",
                                ifelse(length(succ_i) == NumPreferences,
                                       "Complete", "Incomplete"))
    # DEFINE INCOMPARABLE PAIRS DEPENDING ON STATUS
    # IF IS EMPTY, THERE IS NO COMPARABLE PAIR OF HOUSES
    if(Agent[["Status"]] == "Empty"){
      # DEFINE THE INCOMPARABLE SET AS ONE PAIR OF HOUSES (A,B)
      Agent[["Incomparable"]] <- t(combn(1:NumAgents, 2))
      # NOW FOR EACH INCOMPARABLE HOUSE GET BOTH POSSIBLE PREFERENCES, START
      # WITH THE TWO ONES FROM THE FIRST INCOMPARABLE PAIR
      Agent[["Z"]] <- Agent[["Incomparable"]][1,]
      Agent[["Z"]] <- rbind(Agent[["Z"]],
                           rev(Agent[["Incomparable"]][1,]))
      # NOW FOR THE OTHERS PAIRS
      for (z in 2:(length(Agent[["Incomparable"]])/2)) {
        # ADD THE FIRST ONE FROM THAT PAIR
        Agent[["Z"]] <- rbind(Agent[["Z"]],
                              Agent[["Incomparable"]][z,])
        # ADD THE OPPOSITE
        Agent[["Z"]] <- rbind(Agent[["Z"]],
                              rev(Agent[["Incomparable"]][z,]))
      }
    # IF IS COMPLETE
    } else if(Agent[["Status"]] == "Complete"){
      # THERE IS NO INCOMPARABLE PAIR OF HOUSES
      Agent[["Incomparable"]] <- list()
    # IF ARE INCOMPLETE
    } else {
      # DEFINE THE INCOMPARABLE SET AS ALL THE POSSIBLE PAIR OF HOUSES (A,B)
      Agent[["Incomparable"]] <- t(combn(1:NumAgents, 2))
      # NOW CHECK WHICH OF THOSE POSSIBLE PAIR OF HOUSES IS ACTUALLY DEFINED
      # IN THE AGENT'S PREFERENCE. DEFINE DROPROWS AS AN AUXILIARY ELEMENT
      # THAT WILL CONTAIN THE INFORMATION ABOUT THOSE ROWS TO ERASE FROM THE
      # INCOMPARABLE SET BECAUSE IT HAS DEFINED PREFERENCE.
      droprows <- vector()
      # FOR ALL POSSIBLE PAIR IN THE INCOMPARABLE SET
      for(p in 1:nrow(Agent[["Incomparable"]])){
        # EXTRACT THE POSSIBLE PAIR (A,B)
        succ <- Agent$Incomparable[p,]
        # SEE IF THE PAIR (A,B) HAS A DEFINED PREFERENCE, THIS EQUALS TO CHECK 
        # FOR ALL DEFINED PREFERENCES IF THEY ARE EQUALS TO (A,B) OR EQUALS TO
        # (B,A). LET AUX BE A VECTOR THAT STORE THE BOOLEAN (TRUE OR FALSE)
        # RESULT OF COMPARE (A,B) TO EVERY DEFINED ONE
        aux <- vector()
        # FOR EACH DEFINED
        for (defined in succ_i) {
          # SEE IF THE DEFINED IS EQUALS TO (A,B)
          cond1 <- succ[1] == defined[1]
          cond2 <- succ[2] == defined[2]
          # SEE IF THE DEFINED IS EQUALS TO (B,A)
          cond3 <- succ[2] == defined[1]
          cond4 <- succ[1] == defined[2]
          # IF MEETS ANY ADD 1 TO AUX, IF NOT, ADD 0
          aux <- append(aux, ifelse((cond1 & cond2) | (cond3 & cond4), 1, 0))
        }
        # NOW THAT WAS CHECKED FOR EVERY DEFINED PREFERENCE, IF (A,B) HAS NO
        # DEFINED PREFERENCE AUX WILL CONTAIN ONLY 0S AND ITS SUM WILL BE 0. IF
        # HAS A DEFINED PREFERENCE THE SUM WILL BE GREATER THAN 0 AND IT IS A
        # POSSIBLE PAIR THAT MUST BE REMOVED
        if(sum(aux) == 0){
          next
        } else {
          droprows <- append(droprows, p)
        }
      }
      rm(aux, cond1, cond2, cond3, cond4, defined, p, succ)
      Agent$Incomparable <- Agent$Incomparable[-droprows,]
      # NOW FOR EACH INCOMPARABLE HOUSE GET BOTH POSSIBLE PREFERENCES,
      # IF THE NUMBER OF ROWS IN INCOMPARABLE IS ONE
      if(length(Agent$Incomparable) == 2){
        Agent[["Z"]] <- Agent[["Incomparable"]]
        Agent[["Z"]] <- rbind(Agent[["Z"]], rev(Agent[["Incomparable"]]))
        # IF THE NUMBER OF ROWS IN INCOMPARABLE IS GREATER THAN ONE
      } else {
        # START WITH THE TWO ONES FROM THE FIRST INCOMPARABLE PAIR
        Agent[["Z"]] <- Agent[["Incomparable"]][1,]
        Agent[["Z"]] <- rbind(Agent[["Z"]],
                              rev(Agent[["Incomparable"]][1,]))
        # CONTINUE WITH THE OTHERS
        for (z in 2:(length(Agent[["Incomparable"]])/2)) {
          # ADD THE FIRST ONE FROM THAT PAIR
          Agent[["Z"]] <- rbind(Agent[["Z"]],
                                Agent[["Incomparable"]][z,])
          # ADD THE OPPOSITE
          Agent[["Z"]] <- rbind(Agent[["Z"]],
                                rev(Agent[["Incomparable"]][z,]))
        }
      }
    }
    Data[[paste0("Agent_", i)]] <- Agent
  }
  rm(Agent, succ_i, droprows, i, NumPreferences, NumAgents)
  return(Data)
}
