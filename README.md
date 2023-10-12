# Shiny App - Shapley-Scarf housing markets with indecisive agents

This repository store the source code of the Shinny App that I developed as a research assistant of professor Juan Pablo Torres-Martinez at my second year of Master in Economics in University of Chile. This app find the core and strong core in a Housing Market with agents that have incomplete preferences. Is based on the paper "[On Housing Markets with Indecisive Agents](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4461572)" by Emilio Guamán and Juan Pablo Torres-Martínez (2023) and is assumed that the user of the app and reader of this document is familiarized with the paper and topics from a Shapley-Scarf Housing Market. [You can find the app here.](https://nleivad.shinyapps.io/apphousingmarketincompletepreferences/)

In the files you will find:  
- 1
- 2
- 3
- 4
- 5

Next the instructions you must follow in order to the app working correctly. Examples are made in base to the example 1 of the paper:  
1. First you must input the number of agents in this housing maket, everyone is owner of a house indexed with the agent's number. Example: input as Number of Agents 4.
2. Second for each agent you must input **only the defined preferences** relations between two houses once. Example: Agent 1 has the next preferences $\succ_1: h_2 \succ_1 h_3 \succ_1 h_1, \quad h_4 \succ_1 h_3 \succ_1 h_1, \quad h_2 \bigotimes h_4$, so you must input the next text: (2,3),(2,1),(3,1),(4,3),(4,1). Any additional characters than `(`, `,` or `)`, even whitespaces, probably will induce errors and the app may crash. Also note that you can observe two times that $h_3 \succ_1 h_1$ but is inputed only once and that $h_2 \bigotimes h_4$ is not written anywhere, not following this instructions will lead to errors.
3. Repeat the second step for all other agents under the same logic.
4. Press the button "Find the Core and The Strong Core" and wait.

The process may be slow and take a lot of time depending of the case of study, for understand that the first is to understand the process made by this app. This process is divided in six steps, every step that may contain subroutines and a series of steps themselves, what must be checked on each step code. The general idea is the following:
1. First the text input is read and transform to ordered numeric pairs in one list for agent stored in one big list.
2. Second, for each agent this ordered pairs are counted in order to determine if the agent has complete, incomplete or empty preferences. An agent with complete preferences has $\sum_{i=1}^{N-1}i = \frac{N(N-1)}{2}$ ordered pairs, an agent with empty preferences has 0 ordered pairs and an agent with incomplete preferences has any number of ordered pairs between 0 and $\frac{N(N-1)}{2}$. If the agent has incomplete or empty preferences identify the incomparable pairs along with the possible preferences that can be obtained from that incomparable pair. This means that if an agent has as an incomparable pair $h_a \bigotimes h_b$ there can be two possible preferences: $h_a \succ h_b$ or $h_b \succ h_a$.  
3. Third, for each agent that has incomplete or empty preferences define the sequential completions by applying the SC algorithm.
4. Fourth, get all the possible combinatios of preferences profiles. This is as in example 1 of the paper, if the agent one has two completions as also does agent four, thus there are 4 possible scenarios to be constructed from this preferences profiles. Let $\widehat{\succ}_{i,j}$ be the $j$-th completion for agent $i$, in example 1 of the paper we have the next preferences profiles: $\widehat{\succ}_{1,1}, \succ_2, \succ_3, \widehat{\succ}_{4,1}$, $\widehat{\succ}_{1,1}, \succ_2, \succ_3, \widehat{\succ}_{4,2}$, $\widehat{\succ}_{1,2}, \succ_2, \succ_3, \widehat{\succ}_{4,1}$ and $\widehat{\succ}_{1,2}, \succ_2, \succ_3, \widehat{\succ}_{4,2}$.  
5. Apply Top Trading Cycles Algorithm to each scenario made from a combination in the previous step, assign the resulting matching and store in the core and check that the core hasn't repeated matchings.
6. If there are agents with non complete preferences, then get the strong core by checking for every matching $\mu$ in the core that there are no cycles where all agents announce a house at least as good as their house under $\mu$ and at least one agent improves.

Now that the process has been explained you can see that is not computationally efficient, as an example for an extreme case of study with four agents where only one agent has only one preference defined:  
- $\succ_1: h_3 \succ_1 h_2, \quad h_1 \bigotimes h_2, \quad h_1 \bigotimes h_3, \quad h_1 \bigotimes h_4, \quad h_2 \bigotimes h_4, \quad h_3 \bigotimes h_4$
- $\succ_2: h_1 \bigotimes h_2, \quad h_1 \bigotimes h_3, \quad h_1 \bigotimes h_4, \quad h_2 \bigotimes h_3, \quad h_2 \bigotimes h_4, \quad h_3 \bigotimes h_4$
- $\succ_3: h_1 \bigotimes h_2, \quad h_1 \bigotimes h_3, \quad h_1 \bigotimes h_4, \quad h_2 \bigotimes h_3, \quad h_2 \bigotimes h_4, \quad h_3 \bigotimes h_4$
- $\succ_4: h_1 \bigotimes h_2, \quad h_1 \bigotimes h_3, \quad h_1 \bigotimes h_4, \quad h_2 \bigotimes h_3, \quad h_2 \bigotimes h_4, \quad h_3 \bigotimes h_4$

In this case the scenarios resulting from the combinations of all completions for all agents are 165888 scenarios and takes several minutes. Is a challenge for the future determine a formula to get all the possible scenarios resulting from the combinations of all completions.
