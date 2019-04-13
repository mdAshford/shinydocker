## How your grade is calculated

Your grade is a weighted average of your Tests, Homework, and Final Exam scores, as follows:

$$
\begin{gather}  \qquad \notag
 \textbf{OVERALL} = 50 \times \textbf{TEST} + 25 \times \textbf{HOMEWORKS} + 25 \times \textbf{FINAL}
\end{gather}
$$

Here is how it works, with a demo example. Farther down the page are live cells that you can use with your numbers.

$\textbf{HOMEWORKS}$ comes straight from WileyPLUS.
```julia
julia> homeworks = 0.83
0.83
```
$\textbf{FINAL}$ is self-explanatory.
```julia
julia> final = 0.88
0.88
```
$\textbf{TESTS}$ requires a few intermediate calculations. Let's represent your tests by $\left\{T_1, T_2, T_3, T_4 \right\}.$
```julia
julia> T = [83; 71; 89; 97] / 100
4-element Array{Float64,1}:
 0.83
 0.71
 0.89
 0.97
```
1. Calculate average of {**T**}, excluding the lowest one.
$ \qquad \small
\begin{gather} \notag \\ \notag
\textbf{DROP} = \frac{\text{sum} \left\{T_1, T_2, T_3, T_4 \right\} - \text{minimum} \left\{T_1, T_2, T_3, T_4 \right\}}{3}
\end{gather}
$
```julia
julia> drop = (sum(T) - minimum(T)) / 3
0.8966666666666668
```
1. Calculate average of {**T, FINAL**}, excluding the lowest one. This replaces the lowest test with the Final, unless the Final score is lower than all of the tests.
$ \qquad \small
\begin{gather} \notag \\ \notag
\textbf{REPLACE} = \frac{\text{sum} \left\{T_1, T_2, T_3, T_4, \textbf{FINAL} \right\} - \text{minimum} \left\{T_1, T_2, T_3, T_4,\textbf{FINAL} \right\}}{4}
\end{gather}
$
```julia
julia> replace = (sum([T; final]) - minimum([T; final]))/4
0.8925000000000001
```
1. Wrapping up, choose the more favorable calculation
$ \qquad \small
\begin{gather} \notag \\ \notag
\textbf{TESTS} \text{ = maximum\{} \textbf{DROP, REPLACE} \}
\end{gather}
$
```julia
julia> tests = max(drop, replace)
0.8966666666666668
```

**OVERALL** is the weighted average, per the syllabus.
$ \qquad \small
\begin{gather} \notag \\ \notag
 \textbf{OVERALL} = 25 \cdot \textbf{HOMEWORKS} + 50 \cdot \textbf{TEST} +  25 \cdot \textbf{FINAL}
\end{gather}
$
```julia
julia> grade = 25*homeworks + 50*tests + 25*final
87.58333333333334
```

**LETTER GRADE** comes from this lookup table.

score|97|92|90|**87**|82|80|77|72|70|67|62|60|0
-----|--|--|--|------|--|--|--|--|--|--|--|--|-
grade|A+|A |A-|**B+**|B |B-|C+|C |C-|D+|D |D-|F
