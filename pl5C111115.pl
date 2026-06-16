%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prolog 과제 제출 파일
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 과제 1. 경로찾기
%
% navi(A, B)를 실행하면
% A 노드에서 B 노드까지 갈 수 있는 모든 경로를 출력한다.
%
% 출력 순서는 다음 기준으로 맞춘다.
% 1. 먼저 경로 길이가 짧은 것부터 출력한다.
% 2. 길이가 같으면 Path 리스트를 알파벳 순서처럼 비교해서 출력한다.
%    예를 들어 [a,b,e]가 [a,c,e]보다 먼저 나온다.
%
% 모든 경로를 출력한 다음에는
% shortest path(s)를 출력하고,
% 가장 짧은 경로들을 다시 한 번 출력한다.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 아래 edge들은 그림에 있는 선을 코드로 적은 것이다.
% edge(a, b). 는 a와 b 사이에 길이 있다 = 연결되어있다는 뜻이다.
edge(a, b).
edge(a, c).
edge(a, d).
edge(b, d).
edge(b, e).
edge(c, e).
edge(c, f).
edge(d, g).
edge(e, f).
edge(e, g).
edge(f, h).


% 그림의 길은 한쪽 방향으로만 가는 길이 아니라 양방향으로 이동할 수 있는 구조다.
% 그렇기 때문에 edge(X,Y)가 있으면 X에서 Y로도 갈 수 있고,
% Y에서 X로도 갈 수 있게 connected를 따로 만들었다.
connected(X, Y) :- edge(X, Y).
connected(X, Y) :- edge(Y, X).


% path(A, B, Path, Len)
%
% A에서 출발해서 B까지 가는 경로를 Path에 저장한다.
% Len에는 그 경로에 들어있는 노드 개수를 저장한다.
%
% 한 예시로 [a,b,e]는 노드가 3개이므로 Len은 3이다.
path(A, B, Path, Len) :-
    travel(A, B, [A], ReversePath),
    reverse(ReversePath, Path),
    length(Path, Len).


% travel(B, B, Path, Path)
%
% 현재 위치가 목적지와 같으면 더 이상 갈 필요가 없다.
% 지금까지 저장해둔 경로를 그대로 최종 경로로 사용한다.
travel(B, B, Path, Path).


% travel(A, B, Visited, Path)
%
% 아직 목적지에 도착하지 않은 경우이다.
% 현재 위치 A에서 갈 수 있는 다음 노드 Next를 찾는다.
%
% member(Next, Visited)를 검사하는 이유는
% 이미 지나간 노드를 또 방문하면 같은 곳을 계속 도는 문제가 생길 수 있기 때문이다.
% 그래서 한 번 방문한 노드는 다시 가지 않게 했다.
travel(A, B, Visited, Path) :-
    connected(A, Next),
    \+ member(Next, Visited),
    travel(Next, B, [Next|Visited], Path).


% navi(A, B)
%
% 실제로 사용자가 실행하는 부분이다.
% setof를 쓰면 가능한 경로들을 모아서 정렬까지 해준다.
%
% Len-Path 형태로 모으는 이유는
% 먼저 Len 기준으로 정렬되고,
% Len이 같으면 Path 기준으로 정렬되게 하기 위해서이다.
navi(A, B) :-
    setof(Len-Path, path(A, B, Path, Len), Pairs),
    print_all_paths(Pairs),
    writeln('shortest path(s)'),
    Pairs = [MinLen-_|_],
    print_shortest_paths(Pairs, MinLen).


% 모든 경로를 하나씩 출력하는 부분이다.
% 출력 형식은 과제 예시에 맞춰서
% Len=3, Path=[a,b,e]
% 이런 식으로 나오게 했다.
print_all_paths([]).
print_all_paths([Len-Path|Rest]) :-
    format('Len=~w, Path=~w~n', [Len, Path]),
    print_all_paths(Rest).


% 가장 짧은 경로만 출력하는 부분이다.
% Pairs는 이미 길이순으로 정렬되어 있으므로
% 맨 앞에 있는 길이가 최단 길이이다.
%
% Len이 최단 길이와 같으면 출력하고,
% 더 긴 길이가 나오면 더 이상 출력하지 않는다.
print_shortest_paths([], _).
print_shortest_paths([Len-Path|Rest], MinLen) :-
    Len =:= MinLen,
    !,
    writeln(Path),
    print_shortest_paths(Rest, MinLen).
print_shortest_paths(_, _).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 과제 2. N-Queens problem
%
% solve_nqueens(N)을 실행하면
% NxN 체스판에 N개의 퀸을 놓는 모든 경우를 찾는다.
%
% 퀸은 같은 가로줄, 같은 세로줄, 같은 대각선에 있으면 안 된다.
%
% 여기서는 하나의 리스트로 배치를 표현한다.
% 예를 들어 N=4일 때 [2,4,1,3]이라는 뜻은 다음과 같다.
%
% 1번째 행의 퀸은 2번째 열에 있음
% 2번째 행의 퀸은 4번째 열에 있음
% 3번째 행의 퀸은 1번째 열에 있음
% 4번째 행의 퀸은 3번째 열에 있음
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% solve_nqueens(N)
%
% 실제로 사용자가 실행하는 부분이다.
% 가능한 모든 solution을 찾고,
% solution 개수를 먼저 출력한 다음,
% solution들을 오름차순으로 출력한다.
solve_nqueens(N) :-
    findall(Solution, nqueens(N, Solution), Solutions0),
    sort(Solutions0, Solutions),
    length(Solutions, Count),
    format('number of solutions = ~w~n', [Count]),
    print_solutions(Solutions).


% nqueens(N, Solution)
%
% 1부터 N까지의 숫자 리스트를 만든다.
% 이 숫자들은 열 번호를 의미한다.
%
% 예를 들어 N=4이면 [1,2,3,4]를 만들고,
% 이 리스트의 순서를 여러 방식으로 바꿔 보면서
% 퀸들이 서로 공격하지 않는 배치인지 검사한다.
nqueens(N, Solution) :-
    make_range(1, N, Columns),
    permutation_custom(Columns, Solution),
    safe(Solution).


% make_range(A, B, List)
%
% A부터 B까지 숫자를 차례대로 담은 리스트를 만든다.
% 예를 들어 make_range(1, 4, List)를 실행하면
% List는 [1,2,3,4]가 된다.
make_range(A, B, []) :-
    A > B,
    !.
make_range(A, B, [A|Rest]) :-
    A =< B,
    Next is A + 1,
    make_range(Next, B, Rest).


% permutation_custom(List, Perm)
%
% 리스트 안의 원소 순서를 바꿔서 가능한 모든 배치를 만든다.
% Prolog에 permutation이 있긴 하지만,
% 과제 코드가 너무 라이브러리 의존처럼 보이지 않게 직접 작성했다.
permutation_custom([], []).
permutation_custom(List, [X|Perm]) :-
    select_custom(X, List, Rest),
    permutation_custom(Rest, Perm).


% select_custom(X, List, Rest)
%
% List에서 원소 하나 X를 고르고,
% 그 원소를 뺀 나머지 리스트를 Rest로 만든다.
%
% permutation_custom에서 원소를 하나씩 고를 때 사용한다.
select_custom(X, [X|T], T).
select_custom(X, [H|T], [H|Rest]) :-
    select_custom(X, T, Rest).


% safe(Solution)
%
% 만들어진 퀸 배치가 안전한지 검사한다.
% 퀸들이 서로 대각선으로 공격하지 않는지 확인한다.
%
% permutation으로 배치를 만들었기 때문에
% 같은 행과 같은 열은 이미 겹치지 않는다.
% 따라서 여기서는 대각선만 검사하면 된다.
safe([]).
safe([Q|Qs]) :-
    safe(Qs),
    no_attack(Q, Qs, 1).


% no_attack(Q, Qs, Distance)
%
% 현재 퀸 Q와 뒤에 있는 퀸들이 서로 대각선에 있는지 검사한다.
%
% 리스트에서 한 칸 뒤에 있는 퀸은 행 차이가 1,
% 두 칸 뒤에 있는 퀸은 행 차이가 2이다.
% 이 값을 Distance로 사용한다.
%
% 대각선에 있다는 것은 열 차이와 행 차이가 같다는 뜻이다.
% 그래서 abs(Q - Q1) =\= Distance 조건으로 대각선 충돌을 막는다.
no_attack(_, [], _).
no_attack(Q, [Q1|Qs], Distance) :-
    abs(Q - Q1) =\= Distance,
    NextDistance is Distance + 1,
    no_attack(Q, Qs, NextDistance).


% 찾은 solution들을 한 줄에 하나씩 출력한다.
% writeln을 쓰면 [2,4,1,3] 같은 리스트가 예시처럼 출력된다.
print_solutions([]).
print_solutions([Solution|Rest]) :-
    writeln(Solution),
    print_solutions(Rest).