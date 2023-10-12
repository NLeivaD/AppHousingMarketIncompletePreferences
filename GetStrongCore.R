################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# THIS SCRIPT DEVELOP A FUNCTION THAT TAKES A LIST OF ALLOCATIONS AND A LIST OF
# DATA CONTAINING THE INFORMATION OF EACH AGENT, IT IDENTIFIES IF WHEN EACH
# AGENT ARE ANNOUNCING A PREFERRED OR INCOMPARABLE HOUSE RESPECTO TO THE HOUSE
# UNDER THE ALLOCATION THERE ARE CYCLES, IF THERE ARE CYCLES THE ALLOCATION
# DOESN'T BELONG TO THE STRONG CORE, IF THERE AREN'T CYCLES THE ALLOCATION DOES
# BELONG TO THE STRONGO CORE, THE IDEA IS TO GET AS OUTPUT A LIST CONTAINING ALL
# THE ALLOCATIONS THAT ARE IN THE STRONG CORE.
# FIRST IS DEFINED THE FUNCTION ALONG WITH ITS ARGUMENT
GetStrongCore <- function(Core, Data){
  # DEFINE AN EMPTY LIST THAT WILL CONTAIN ALLOCATIONS IN THE STRONG CORE
  StrongCore <- list()
  # CHECK CONDITIONS FOR EACH ALLOCATION IN THE CORE
  for (mu in Core) {
    # DEFINE S_mu AS THE SET OF CYCLES WHERE ALL AGENTS ANNOUNCE A HOUSE AT
    # LEAST AS GOOD AS THE HOUSE UNDER MU OR AN INCOMPARABLE ONE, AND AT LEAST
    # ONE OF THE AGENT HAS A STRICTLY BETTER HOUSE
    S_mu <- list()
    # DEFINE THE LIST Is THAT STORE FOR EACH AGENT THE SET I(MU)
    Is <- list()
    # FOR EACH AGENT
    for (i in mu$Agent) {
      # GET THE HOUSE UNDER MU
      h <- mu$House[i]
      # DEFINE A LIST TO STORE HOUSES IN I(MU)
      I_i <- list(h)
      # DEFINE THE STATUS OF THE AGENT PREFERENCES
      Status <- Data[[paste0("Agent_",i)]]$Status
      # IF STATUS IS INCOMPLETE
      if(Status == "Incomplete"){
        # GET INCOMPARABLES HOUSES
        Incom <- Data[[paste0("Agent_",i)]]$Incomparable
        # IF THERE IS ONLY ONE INCOMPARABLE PAIR
        if(length(Incom) == 2){
          # CHECK IF THE HOUSE UNDER MU IS IN THIS INCOMPARABLE PAIR
          if(h %in% Incom){
            # APPEND THE INCOMPARABLE HOUSE
            I_i <- append(I_i, setdiff(Incom, h))
          }
          # IF THERE IS MORE THAN ONE INCOMPARABLE PAIR
        } else {
          # FOR EACH ROW OF INCOMPARABLE PAIRS
          for (row in 1:nrow(Incom)) {
            # GET THE INCOMPARABLE PAIR
            Pair <- Incom[row,]
            # CHECK IF THE HOUSE UNDER MU IS IN THIS INCOMPARABLE PAIR
            if(h %in% Pair){
              # APPEND THE INCOMPARABLE HOUSE
              I_i <- append(I_i, setdiff(Pair, h))
            }
            rm(Pair)
          }
          rm(row)
        }
        # NOW ADD THE PREFERRED HOUSES. EXTRACT THE DEFINED PREFERENCES
        succ_i <- Data[[paste0("Agent_", i)]][[paste0("succ_",i)]]
        # FOR EACH DEFINED PREFERENCE
        for (succ in succ_i) {
          # IF THE HOUSE UNDER MU IS THE LESS PREFERRED
          if(h == succ[2]){
            # APPEND THE PREFERRED HOUSE
            I_i <- append(I_i, succ[1])
          }
        }
        # NOW IF THE PREFERENCE IS COMPLETE
      } else if(Status == "Complete"){
        # EXTRACT THE DEFINED PREFERENCES
        succ_i <- Data[[paste0("Agent_", i)]][[paste0("succ_",i)]]
        # FOR EACH DEFINED PREFERENCE
        for (succ in succ_i) {
          # IF THE HOUSE UNDER MU IS THE LESS PREFERRED
          if(h == succ[2]){
            # APPEND THE PREFERRED HOUSE
            I_i <- append(I_i, succ[1])
          }
        }
        # NOW IF THE PREFERENCE IS EMPTY
      } else {
        # AS ALL THE HOUSES ARE INCOMPARABLE, ALL OTHER HOUSES ARE IN I(MU) 
        I_i <- append(I_i, setdiff(1:Data$NumAgents, h))
      }
      # STORE I(MU) FOR THE AGENT IN Is SET
      Is[[paste0("I_", i)]] <- I_i
    }
    rm(I_i, Incom, succ_i, h, i, Status, succ)
    # NOW DEFINE A DATA FRAME THAT CONTAIN IN EACH ROW A POSSIBLE ANNOUNCEMENT
    # AND IN EACH COLUMN THE ANNOUNCEMENT OF THE RESPECTIVE AGENT.
    # START WITH AGENT 1, EACH HOUSE IN I_1 WILL BE REPEATED THE PRODUCT OF THE
    # LENGTH OF I_i FOR THE OTHER AGENTS
    NumReps <- prod(sapply(Is[-1], length))
    # NOW DEFINE THE COLUMN AS EMPTY FIRST
    Agent1 <- vector()
    # ADD EACH ELEMENT OF I_1 NumReps TIMES
    for (h in 1:length(Is[[1]])) {
      # APPEND EACH ELEMENT REPEATED
      Agent1 <- append(Agent1, rep(unlist(Is[[1]][h]), NumReps))
    }
    # NOW DEFINE THE DATA FRAME
    Announcement <- data.frame(Agent1 = matrix(Agent1, ncol = 1))
    # FOR THE REST OF THE AGENTS
    for (a in 2:length(Is)) {
      # CHECK IF IT IS THE LAST
      if(a == length(Is)){
        # THEN THE I_i WILL BE REPEATED AS IS AS MANY TIMES AS THE PRODUCT OF
        # THE LENGTH OF THE PREVIOUS
        NumReps <- prod(sapply(Is[-a], length))
        # ADD THE COLUMN TO THE DATA FRAME
        Agent <- unlist(Is[[paste0("I_",a)]])
        Announcement[paste0("Agent",a)] <- rep(Agent, NumReps)
        # IF ISN'T THE LAST ONE
      } else {
        # THE NUMBER OF REPS WILL BE THE PRODUCT OF THE LENGTH OF THE NEXT ONES
        NumReps <- prod(sapply(Is[-c(1:a)], length))
        # NOW DEFINE THE COLUMN AS EMPTY FIRST
        Agent <- vector()
        # ADD EACH ELEMENT OF I_1 NumReps TIMES
        for (h in 1:length(Is[[a]])) {
          # APPEND EACH ELEMENT REPEATED
          Agent <- append(Agent, rep(unlist(Is[[a]][h]), NumReps))
        }
        # THIS VECTOR WILL BE REPEATED AS MANY TIMES AS THE PRODUCT OF LENGTH OF
        # THE PREVIOUS
        NumReps2 <- prod(sapply(Is[c(1:(a-1))], length))
        Announcement[paste0("Agent",a)] <- rep(Agent, NumReps2)
      }
    }
    # NOW WITH THE DIFFERENT ANNOUNCEMENT DEFINED, LET'S CHECK THOSE WHERE IS A
    # CYCLE AND CHECK IF THE CYCLE ALLOCATES SOMEONE TO A BETTER HOUSE
    # FOR EACH ANNOUNCEMENT. FIRST DEFINE AN EMPTY LIST THAT WILL STORE THE
    # CYCLES
    Cycles <- list()
    # NOW FOR EACH ANNOUNCEMENT
    for (a in 1:nrow(Announcement)) {
      # GET THE ANNOUNCEMENT
      An <- Announcement[a,]
      # THERE CAN BE CYCLES THAT STARTS WITH EACH AGENT SO FOR EACH AGENT
      for (i in 1:ncol(Announcement)) {
        # DEFINE THE AGENT AS A POINTER
        Pointer <- i
        # DEFINE ALL THE POINTERS
        Pointers <- Pointer
        # DEFINE THE HOUSE THAT THE AGENT ANNOUNCE AS POINTED
        Pointed <- as.numeric(An[i])
        # DEFINE ALL THE POINTEDS
        Pointeds <- Pointed
        # UNTIL NOW YOU HAVE CHECKED FOR ONE AGENT IF THERE IS A CYCLE
        AgentsRevised <- 1
        # YOU SHOULD TRY UNTIL YOU CHECKED ALL AGENTS
        for(j in 2:Data$NumAgents){
          # CHECK IF THE POINTED IS IN POINTERS, THERE WILL BE A CYCLE
          if((Pointed %in% Pointers) & (Pointed == i)){
            # NOW GET THE ANNOUNCED CYCLE
            Cycle <- data.frame(Pointer = Pointers, Pointed = Pointeds)
            # ORDER THIS CYCLE BY THE POINTER COLUMN
            Cycle <- Cycle[order(Cycle$Pointer),]
            # SET ROWNAMES FROM 1 TO NROWS
            row.names(Cycle) <- 1:nrow(Cycle)
            # ADD TO THE CYCLES LIST
            Cycles <- append(Cycles, list(Cycle))
            # KEEP UNIQUE CYCLES
            Cycles <- unique(Cycles)
            # HERE ENDS THE CHECK FOR ALL AGENTS INVOLVED IN THE CYCLE, THE NEXT
            # LINES ARE IF A CYCLE HASN'T BE FOUND YET.
            # IF POINTED IS NOT IN POINTERS
            break
          } else {
            # DEFINE THE NEW POINTER
            Pointer <- Pointed
            # ADD THE NEW POINTER TO POINTERS
            Pointers <- c(Pointers, Pointed)
            # DEFINE THE NEW POINTED
            Pointed <- as.numeric(An[Pointer])
            # ADD THE NEW POINTED TO POINTEDS
            Pointeds <- c(Pointeds, Pointed)
          }
        }
      }
    } 
    # NOW YOU HAVE ALL THE CYCLES, SO THE NEXT PROCEDURE IS TO CHECK IF THE 
    # CYCLE LEAVES SOMEONE STRICTLY BETTER, SO FOR EACH CYCLE
    for (Cycle in Cycles) {
      # CHECK FOR EACH AGENT INVOLVED IN THIS CYCLE
      for (row in 1:nrow(Cycle)) {
        # DEFINE THE AGENT
        Agent <- Cycle$Pointer[row]
        # DEFINE ITS ANNOUNCED HOUSE IN THE CYCLE
        h_prime <- Cycle$Pointed[row]
        # DEFINE ITS HOUSE UNDER MU
        h <- mu$House[Agent]
        # CHECK IF THE HOUSE IS THE SAME
        if(h_prime == h){
          # IF IT IS, THIS AGENT HASN'T IMPROVED SO MOVE ON
          next
          # IF IT IS NOT
        } else {
          # CHECK IF THE PREFERENCE IS EMPTY
          if(Data[[paste0("Agent_", Agent)]]$Status == "Empty"){
            # IF IT IS THERE IS NO PREFERRED HOUSE
            next
            # IF IT IS NOT EMPTY, IF IS COMPLETE OR INCOMPLETE
          } else {
            # GET THE DEFINED PREFERENCES
            defined <- as.data.frame(matrix(unlist(Data[[paste0("Agent_", Agent)]][[paste0("succ_", Agent)]]), 
                              ncol = 2, byrow = T))
            # LEAVE THE DEFINED PREFERENCES WHERE THE HOUSE UNDER THIS CYCLE IS
            # PREFERRED
            defined <- defined[which(defined$V1 == h_prime),]
            # IF THERE IS NO PREFERENCES WHERE THE HOUSE UNDER THE CYCLE IS 
            # PREFERRED
            if(nrow(defined) == 0){
              # SKIP TO THE NEXT AGENT
              next
              # IF ARE PREFERENCES WHERE IS PREFERRED
            } else {
              # LEAVE THE DEFINED PREFERENCES WHERE THE HOUSE UNDER MU IS LESS
              # PREFERRED
              defined <- defined[which(defined$V2 == h),]
              # IF THERE IS DEFINED PREFERENCES
              if(nrow(defined) > 0){
                # THE CYCLE GOES TO S_mu
                S_mu <- append(S_mu, list(Cycle))
                # CHECK FOR NO REPEATED CYCLES
                S_mu <- unique(S_mu)
              }
            }
          }
          # NOW WAS CHECKED FOR ALL DEFINED PREFERENCES IF THE AGENT
          # IMPROVES ITS HOUSE
        }
        # NOW WAS CHECKED IF AN AGENT WITH A DIFFERENT HOUSE IN THIS CYCLE
        # IMPROVES OR NOT
      }
    }
    # FROM HERE IS ALREADY DEFINED IS S_mu IS EMPTY OR NOT, IF EMPTY ADD THE
    # MATCHING TO THE STRONGCORE
    if(length(S_mu) == 0){
      StrongCore <- append(StrongCore, list(mu))
    }
  }
  return(StrongCore)
}
