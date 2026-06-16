;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lisp 과제 제출 파일
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 과제 1. 경로찾기
;; 시작 노드에서 도착 노드까지 갈 수 있는 경로를 찾는 문제다.
;; 이미 방문한 노드는 다시 가지 않게 해서 반복되는 길은 막았다.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 그림에 있는 연결 관계를 적어둔 것이다.
;; 여기서는 일단 한 방향으로 적고 아래에서 양방향처럼 처리했다.
(defparameter *edges*
  '((a b)
    (a c)
    (a d)
    (b d)
    (b e)
    (c e)
    (c f)
    (d g)
    (e f)
    (e g)
    (f h)))


;; 노드 이름을 비교할 때 사용한다.
;; 길이가 같은 경로를 정렬할 때 필요했다.
(defun symbol-name-less-p (x y)
  (string< (symbol-name x) (symbol-name y)))


;; 현재 노드에서 바로 갈 수 있는 노드들을 찾는다.
;; edge를 양방향처럼 봐야 해서 앞뒤를 둘 다 확인했다.
(defun neighbors (node)
  (sort
   (remove-duplicates
    (append
     (mapcar #'second
             (remove-if-not
              (lambda (edge) (eql (first edge) node))
              *edges*))
     (mapcar #'first
             (remove-if-not
              (lambda (edge) (eql (second edge) node))
              *edges*)))
    :test #'eql)
   #'symbol-name-less-p))


;; DFS 방식으로 가능한 경로를 찾는다.
;; 목적지에 도착하면 지금까지 온 길을 하나의 경로로 저장한다.
(defun find-paths-dfs (current goal visited)
  (cond
    ((eql current goal)
     (list (reverse visited)))

    (t
     (let ((result nil))
       (dolist (next (neighbors current) result)
         ;; 이미 지나간 노드는 다시 가지 않는다.
         (unless (member next visited :test #'eql)
           (setf result
                 (append result
                         (find-paths-dfs next goal (cons next visited))))))))))


;; 시작 노드에서 도착 노드까지 가능한 모든 경로를 구한다.
(defun find-all-paths (start goal)
  (find-paths-dfs start goal (list start)))


;; 경로끼리 알파벳 순서처럼 비교한다.
;; 앞부분이 같으면 다음 노드를 비교하는 식이다.
(defun path-lex-less-p (p1 p2)
  (cond
    ((and (null p1) (null p2)) nil)
    ((null p1) t)
    ((null p2) nil)
    ((eql (car p1) (car p2))
     (path-lex-less-p (cdr p1) (cdr p2)))
    (t
     (symbol-name-less-p (car p1) (car p2)))))


;; 경로 정렬 기준이다.
;; 길이가 짧은 경로를 먼저 두고, 길이가 같으면 노드 순서로 비교했다.
(defun path-less-p (p1 p2)
  (let ((len1 (length p1))
        (len2 (length p2)))
    (cond
      ((< len1 len2) t)
      ((> len1 len2) nil)
      (t (path-lex-less-p p1 p2)))))


;; 모든 경로를 찾고 정렬까지 한다.
(defun sorted-paths (start goal)
  (sort (copy-list (find-all-paths start goal)) #'path-less-p))


;; 과제 1 실행 함수다.
;; 출력 형식을 맞추기 위해 format을 사용했다.
(defun get_sorted_paths (start goal)
  (let ((paths (sorted-paths start goal)))
    (format t "paths from ~A to ~A~%" start goal)
    (format t "number of paths = ~A~%" (length paths))

    ;; 경로 앞에 길이를 붙여서 출력한다.
    (dolist (path paths)
      (format t "~S~%" (cons (length path) path)))

    ;; 과제 1에서는 출력 사진에 NIL이 없어서 마지막에 NIL이 안 나오게 했다. => 값 반환으로 처리
    (values)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 과제 2. N-Queens problem
;; N x N 체스판에 퀸 N개를 놓는 문제다.
;; 같은 행, 같은 열, 같은 대각선에 퀸이 있으면 안 된는 문제다.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; start부터 end까지 숫자 리스트를 만든다.
;; 1부터 4까지면 (1 2 3 4)가 된다.
(defun make-range (start end)
  (if (> start end)
      nil
      (cons start (make-range (+ start 1) end))))


;; 리스트에서 원소 하나를 제거한다.
;; 순열을 만들 때 사용한다.
(defun remove-one (x lst)
  (cond
    ((null lst) nil)
    ((eql x (car lst)) (cdr lst))
    (t (cons (car lst) (remove-one x (cdr lst))))))


;; 가능한 열 배치를 전부 만들어본다.
;; 여기서 만들어지는 리스트 하나가 퀸 배치 후보가 된다.
(defun make-permutations (lst)
  (if (null lst)
      (list nil)
      (let ((result nil))
        (dolist (x lst result)
          (dolist (perm (make-permutations (remove-one x lst)))
            (push (cons x perm) result))))))


;; 현재 퀸이 뒤에 있는 퀸들과 대각선으로 겹치는지 확인한다.
;; 행 차이와 열 차이가 같으면 대각선에 있는 것이다.
(defun no-diagonal-attack-p (col rest distance)
  (cond
    ((null rest) t)
    ((= (abs (- col (car rest))) distance) nil)
    (t
     (no-diagonal-attack-p col (cdr rest) (+ distance 1)))))


;; 하나의 배치가 가능한 배치인지 확인한다.
;; 순열로 만들었기 때문에 같은 열은 이미 겹치지 않아서 대각선만 검사했다.
(defun safe-solution-p (solution)
  (cond
    ((null solution) t)
    (t
     (and
      (no-diagonal-attack-p (car solution) (cdr solution) 1)
      (safe-solution-p (cdr solution))))))


;; solution들을 오름차순으로 출력하기 위해 비교한다.
(defun number-list-less-p (l1 l2)
  (cond
    ((and (null l1) (null l2)) nil)
    ((null l1) t)
    ((null l2) nil)
    ((= (car l1) (car l2))
     (number-list-less-p (cdr l1) (cdr l2)))
    (t
     (< (car l1) (car l2)))))


;; 과제 2 실행 함수다.
;; solution 개수를 먼저 출력하고, 그 다음 배치들을 출력한다.
(defun nqueens (n)
  (let* ((columns (make-range 1 n))
         (candidates (make-permutations columns))
         (solutions
          (sort
           (remove-if-not #'safe-solution-p candidates)
           #'number-list-less-p)))
    (format t "~Ax~A n-queens problem~%" n n)
    (format t "number of solutions = ~A~%" (length solutions))

    ;; solution을 한 줄씩 출력한다.
    (dolist (solution solutions)
      (format t "~S~%" solution))))