# DEFINE EXAMPLES TO TEST, THERE ARE TWO MAIN CATEGORIES OF EXAMPLES:
# 1. PAPER EXAMPLES - THE EXAMPLES IN GUAMAND AND TORRES-MARTINEZ'S PAPER:
#                     "On Housing Markets with Indecisive Agents".
# 2. ADDITIONAL EXAMPLES - THOSE THAT AREN'T IN THE PAPER AND EXTEND THE CASES
#                          OF THE PAPER
# THE EXAMPLES HAS TWO CHECK STATUS:
# A. CHECK - THIS MEANS THE EXAMPLE HAS BEEN CHECKED ON THE APP'S WEB
# B. CHECK IN R - THIS MEANS THE EXAMPLE HAS BEEN CHECKED ONLY IN R SOURCE CODE
#                 BUT HASN'T BEEN CHECKED ON THE APP'S WEB
## 1. PAPER EXAMPLES
### EXAMPLE 1, 3, 6, 7 AND A1 - CHECK
input <- list(NumAgents = 4,
              succ_1 = "(2,3),(3,1),(2,1),(4,3),(4,1)",
              succ_2 = "(1,2),(1,3),(1,4),(2,3),(2,4),(3,4)",
              succ_3 = "(1,4),(1,3),(1,2),(4,3),(4,2),(3,2)",
              succ_4 = "(2,4),(2,1),(4,1),(2,3),(3,1)")
### EXAMPLE 2 AND 8 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(3,1),(3,2),(1,2)",
              succ_2 = "(3,2),(3,1),(2,1)",
              succ_3 = "(1,3),(2,3)")
### EXAMPLE 4 ONLY EXPLAINS HOW STC WORKS
### EXAMPLE 5
#### EXAMPLE 5 - PROFILE 1 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(2,3),(2,1),(3,1)",
              succ_2 = "(1,3),(1,2),(3,2)",
              succ_3 = "(1,2),(1,3),(2,3)")
#### EXAMPLE 5 - PROFILE 2 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(2,1),(3,1)",
              succ_2 = "(1,3),(1,2),(3,2)",
              succ_3 = "(1,2),(1,3),(2,3)")
#### EXAMPLE 5 - PROFILE 3 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(2,1),(3,1)",
              succ_2 = "(1,2),(3,2)",
              succ_3 = "(1,2),(1,3),(2,3)")
#### EXAMPLE 5 - PROFILE 4 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(2,1),(3,1)",
              succ_2 = "(1,2),(3,2)",
              succ_3 = "(1,3),(2,3)")
#### EXAMPLE 5 - PROFILE 5 AND EXAMPLE A2 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "",
              succ_2 = "(1,2)",
              succ_3 = "(1,3)")
#### EXAMPLE 5 - PROFILE 6 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(1,2),(1,3)",
              succ_2 = "(1,3),(1,2),(3,2)",
              succ_3 = "(1,2),(1,3),(2,3)")
#### EXAMPLE 5 - PROFILE 7 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(1,3)",
              succ_2 = "(1,3),(1,2),(3,2)",
              succ_3 = "(1,2),(1,3),(2,3)")
### EXAMPLE 9 - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(3,2),(3,1),(2,1)",
              succ_2 = "(3,1),(3,2),(1,2)",
              succ_3 = "(1,3),(2,3)")
## ADDITIONAL EXAMPLES, MORE AGENTS OR MORE INDEFINTIONS
### 3 AGENTS
#### ALL ONE PREFERENCES RELATION DEFINED - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "(1,3)")
#### TWO AGENTS WITH ONE PREFERENCES RELATION DEFINED, ONE WITHOUT ANY
#### PREFERENCES RELATION DEFINED - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "")
#### ONE AGENT WITH ONE PREFERENCES RELATION DEFINED, TWO AGENTS WITHOUT ANY
#### PREFERENCES RELATION DEFINED - CHECK
input <- list(NumAgents = 3,
              succ_1 = "(3,2)",
              succ_2 = "",
              succ_3 = "")
#### ALL AGENTS WITHOUT PREFERENCES RELATION DEFINED - CHECK IN R
input <- list(NumAgents = 3,
              succ_1 = "",
              succ_2 = "",
              succ_3 = "")
### 4 AGENTS
#### ALL ONE PREFERENCES RELATION DEFINED - CHECK
input <- list(NumAgents = 4,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "(1,3)",
              succ_4 = "(1,4)")
#### THREE AGENTS WITH ONE PREFERENCES RELATION DEFINED, ONE WITHOUT ANY
#### PREFERENCES RELATION DEFINED - CHECK IN R
input <- list(NumAgents = 4,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "(1,3)",
              succ_4 = "")
#### TWO AGENTS WITH ONE PREFERENCES RELATION DEFINED, TWO WITHOUT ANY
#### PREFERENCES RELATION DEFINED - CHECK IN R (82944 SCENARIOS)
input <- list(NumAgents = 4,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "",
              succ_4 = "")
#### ONE AGENT WITH ONE PREFERENCES RELATION DEFINED, THREE WITHOUT ANY
#### PREFERENCES RELATION DEFINED - CHECK IN R (165888 SCENARIOS)
input <- list(NumAgents = 4,
              succ_1 = "(3,2)",
              succ_2 = "",
              succ_3 = "",
              succ_4 = "")
#### ALL AGENTS WITHOUT PREFERENCES RELATION DEFINED - CHECK IN R (331776 SCENARIODS)
input <- list(NumAgents = 4,
              succ_1 = "",
              succ_2 = "",
              succ_3 = "",
              succ_4 = "")
### 5 AGENTS
#### ALL ONE PREFERENCES RELATION DEFINED - HIGH EXECUTION TIME, MORE THAN ONE
#### DAY
input <- list(NumAgents = 5,
              succ_1 = "(3,2)",
              succ_2 = "(3,1)",
              succ_3 = "(1,3)",
              succ_4 = "(1,4)",
              succ_5 = "(1,5)")