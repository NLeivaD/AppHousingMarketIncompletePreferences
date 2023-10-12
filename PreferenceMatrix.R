################################################################################
### GUAMAN AND TORRES-MARTINEZ (2023) - ON HOUSING MARKETS WITH INDECISIVE   ###
### AGENTS - SHINY APP BY NICOLAS LEIVA DIAZ - VERSION 1.0 OCTOBER 2023      ###
### NLEIVAD@FEN.UCHILE.CL - NS.LEIVA.D@GMAIL.COM                             ###
################################################################################

# This script define a function called PreferenceMatrix that orders a list of
# preferences and returns a preferences matrix where the i-th column represents 
# the ranking of preference that the agent i gives to the houses, so column i
# row 1 is the top house to the agent i, column i row 2 is the second prefered
# house for the agent i, and so on. Also the funciton assume that the elements
# of the list are in order with the agent number, so assume that the first
# element in the list is the preferences of the agent 1, the second element in
# list are preferences of agent 2, etc... This function is developed in order to 
# replicates the results of Guaman and Torres-Martinez (2023) paper: 
# "Coalitional stability and incentives in housing markets with incomplete 
# preferences", is developed by Nicolas Leiva. Any error in this code
# is from my exclusive responsability.

PreferenceMatrix <- function(PreferenceProfile){
  if(class(PreferenceProfile) != "list"){
    stop("Preference Profile must be a non-empty list.")
  }
  NumAgents = length(PreferenceProfile)
  # 2 agents <- 1 preference
  # 3 agents <- 3 preferences
  # 4 agents <- 6 preferences
  # 5 agents <- 10 preferences
  # 6 agents <- 15 preferences
  # 7 agents <- 21 preferences
  # n agents <- (sum_{i=1}^{n-1} i) preferences
  NumPreferences = sum(1:(NumAgents-1))
  for(i in 1:NumAgents){
    if(length(PreferenceProfile[[i]]) != NumPreferences){
      stop(paste0("Each agent should have complete preferences, as you have ",
                  NumAgents, " agents, each agent must have ", NumPreferences,
                  " preferences. Please check agent ", i, "."))
    }
  }
  P <- matrix(nrow = NumAgents, ncol = NumAgents)
  for (i in 1:NumAgents) {
    pref <- PreferenceProfile[[i]] # Extract the list with i-th agent preference
    pref_m = matrix(unlist(pref), ncol = 2, byrow = T) # Transform to a matrix
    pref_m <- unique(pref_m) # As a precaution check for repeated pairs 
    times <- c(1, sum(pref_m[, 1] == 1)) # Create a vector to count, add house 1
    for (x in 2:NumAgents) { # For each of the other houses repeat
      counts <- c(x, sum(pref_m[, 1] == x)) # Count how many times is prefered
      times <- rbind(times, counts) # Add the count to times
    }
    idx <- order(times[, 2], decreasing = T) # Order by decreasing order
    P[,i] <- matrix(times[idx, 1], ncol = 1) # Assign to the matrix
  }
  return(P)
}
