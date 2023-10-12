################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# This script define a function called SC that apply the Sequential Completion 
# Algorithm that allows to complete the preferences that are incompletes without 
# compromising transitivity. This algorithm basically creates different 
# scenarios where are complete preferences. The function takes a list containing 
# multiple lists that are preferences of an agent, apply the Sequential 
# Completion Algorithm (SC) to the incomplete ones and returns the different scenarios in a list that contains:
# 1.- Original Preferences.
# 2.- Preferences after apply the STC algorithm.
# 3.- Different scenarios with the names of the preferences.
SC <- function(Data){
  NumAgents <- Data$NumAgents
  for (s in 1:NumAgents) { # For each agent
    # If preferences are complete
    if(Data[[paste0("Agent_", s)]]$Status == "Complete"){
      # Skip to the next agent
      next
      # Now if the preference is incomplete
    } else if(Data[[paste0("Agent_", s)]]$Status == "Incomplete"){
      # Define succ_i_j as the jth transitive completion for the ith agent,
      # start with assign the defined preferences
      succ_i <- Data[[paste0("Agent_", s)]][[paste0("succ_",s)]]
      # Now for each incomparable pair of houses, count how many pairs are
      NumIncom <- length(Data[[paste0("Agent_", s)]]$Incomparable)/2
      # Define a number of completion preference
      NumComp <- 0
      # If the number of incomparable pairs is 1 the case is simple and get
      # only two possible scenarios
      if(NumIncom == 1){
        # For each scenario
        for (j in 1:nrow(Data[[paste0("Agent_",s)]]$Z)) {
          # Build the complete preference profile with the completion
          succ_i_j <- append(succ_i, 
                             list(Data[[paste0("Agent_",s)]]$Z[j,]))
          # Check if is transitive this completion
          if(CheckTransitivity(succ_i_j) == "Non Transitive"){
            # If isn't go to the next execution
            next
            # Instead if is transitive
          } else {
            # Add 1 to the number of completion profile
            NumComp <- NumComp + 1
            # Assign this completion to the agent's information
            Data[[paste0("Agent_",s)]][[paste0("succ_",s,"_",NumComp)]] <- succ_i_j
          }
        }
        Data[[paste0("Agent_",s)]][["NumComp"]] <- NumComp
        # If the number of incomparable pairs is greater than one
      } else {
        # Now if the number of incomparable pairs is greater than one, create a 
        # data frame where each column will be the options of each pair. This mean
        # if there is two incomparable pairs (a,b) and (c,d), in the set Z
        # there is four elements (a,b),(b,a),(c,d),(d,c) in that order of rows. So
        # the data frame will contain two columns as follows:
        # 1 3
        # 1 4
        # 2 3
        # 2 4
        # For example 1 3 means (a,b) with (c,d), 1 4 means (a,b) with (d,c) and
        # so on. Note that if the number of incomparable pairs is N, then there
        # will be 2^N different combinations. Every pair will repeat each value
        # 2^(N-1) times, to make this in order, the first column will contain the
        # row number of the first two rows of Z and will repeat this first two row 
        # numbers 2^(N-1) times each, first 1 and then the same amount of times 2
        # The second column, that will contains the row numbers 3 and 4 will
        # repeat each row number 2^(N-2) times and that sequence 2 times, let 
        # RepTimes be this amount of reps for each row number, start with the
        # first two
        RepTimes <- 2^(NumIncom-1)
        # Define the data frame
        combinations <- data.frame(Row1 = c(rep(1, RepTimes),
                                            rep(2, RepTimes)))
        # Now repeat for the next incomparable pairs
        for (i in 2:NumIncom) {
          # RepTimes
          RepTimes <- 2^(NumIncom - i)
          # Row Numbers
          RowNumbers <- ((2*(i-1)+1):(2*(i-1)+2))
          # The sequence to add
          combinations[paste0("Row",i)] <- rep(c(rep(RowNumbers[1], RepTimes),
                                                 rep(RowNumbers[2], RepTimes)),
                                               2^(i-1))
        }
        # Now each row of combinations is a scenario of completion
        # For each scenario
        for (j in 1:nrow(combinations)) {
          # Build the complete preference profile with the completion, start
          # with create succ_i_j as the jth completion for ith agent
          succ_i_j <- Data[[paste0("Agent_",s)]][[paste0("succ_",s)]]
          # Now add each row of Z pointed in each col of combinations
          for (col in 1:ncol(combinations)) {
            RowNumber <- combinations[j,col]
            succ_i_j <- append(succ_i_j, 
                               list(Data[[paste0("Agent_",s)]]$Z[RowNumber,]))
          }
          # Check if is transitive this completion
          if(CheckTransitivity(succ_i_j) == "Non Transitive"){
            # If isn't go to the next execution
            next
            # Instead if is transitive
          } else {
            # Add 1 to the number of completion profile
            NumComp <- NumComp + 1
            # Assign this completio to the agent's information
            Data[[paste0("Agent_",s)]][[paste0("succ_",s,"_",NumComp)]] <- succ_i_j
          }
        }
        Data[[paste0("Agent_",s)]][["NumComp"]] <- NumComp
      }
      # Finally if is an empty preference
    } else {
      # Define the number of incomparable pairs
      NumIncom <- length(Data[[paste0("Agent_", s)]]$Incomparable)/2
      # Define a number of completion preference
      NumComp <- 0
      # If the number of incomparable pairs is 1 the case is simple and get
      # only two possible scenarios, this case for an Agent with empty 
      # preferences occur only when there are two agents and the agent doesn't
      # know how to compare the only two available houses
      if(NumIncom == 1){
        # For each scenario
        for (j in 1:nrow(Data[[paste0("Agent_",s)]]$Z)) {
          # Build the complete preference profile with the completion
          succ_i_j <- list(Data[[paste0("Agent_",s)]]$Z[j,])
          # As there will be only two options to compare only two houses it is 
          # not necessary to check transitivity
          # Add 1 to the number of completion profile
          NumComp <- NumComp + 1
          # Assign this completion to the agent's information
          Data[[paste0("Agent_",s)]][[paste0("succ_",s,"_",NumComp)]] <- succ_i_j
        }
        Data[[paste0("Agent_",s)]][["NumComp"]] <- NumComp
        # If the number of incomparable pairs is greater than one
      } else {
        RepTimes <- 2^(NumIncom-1)
        # Define the data frame
        combinations <- data.frame(Row1 = c(rep(1, RepTimes),
                                            rep(2, RepTimes)))
        # Now repeat for the next incomparable pairs
        for (i in 2:NumIncom) {
          # RepTimes
          RepTimes <- 2^(NumIncom - i)
          # Row Numbers
          RowNumbers <- ((2*(i-1)+1):(2*(i-1)+2))
          # The sequence to add
          combinations[paste0("Row",i)] <- rep(c(rep(RowNumbers[1], RepTimes),
                                                 rep(RowNumbers[2], RepTimes)),
                                               2^(i-1))
        }
        # Now each row of combinations is a scenario of completion
        # For each scenario
        for (j in 1:nrow(combinations)) {
          # Build the complete preference profile with the completion, start
          # with create succ_i_j as the jth completion for ith agent with the
          # first row pointed in the col of combinations
          RowNumber <- combinations[j,1]
          succ_i_j <- list(Data[[paste0("Agent_",s)]]$Z[RowNumber,])
          # Now add each row of Z pointed in each col of combinations
          for (col in 2:ncol(combinations)) {
            RowNumber <- combinations[j,col]
            succ_i_j <- append(succ_i_j,
                               list(Data[[paste0("Agent_",s)]]$Z[RowNumber,]))
          }
          # Check if is transitive this completion
          if(CheckTransitivity(succ_i_j) == "Non Transitive"){
            # If isn't go to the next execution
            next
            # Instead if is transitive
          } else {
            # Add 1 to the number of completion profile
            NumComp <- NumComp + 1
            # Assign this completio to the agent's information
            Data[[paste0("Agent_",s)]][[paste0("succ_",s,"_",NumComp)]] <- succ_i_j
          }
        }
        Data[[paste0("Agent_",s)]][["NumComp"]] <- NumComp
      }
    }
  }
  return(Data)
}
