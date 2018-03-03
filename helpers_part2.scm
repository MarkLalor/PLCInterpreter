#!/usr/bin/racket
#lang racket

(require "abstractions_part2.scm")
(provide (all-defined-out))

; remove the first variable and value from the state list
(define cdrstate
  (lambda (s)
    (cons (cdr (var-list s)) (cons (cdr (value-list s)) '()))))

; 
(define int-exp?
  (lambda (exp)
    (cond
      ((number? exp) #t)
      ((and (list? exp)
            (or
             (eq? (operator exp) '+)
             (eq? (operator exp) '-)
             (eq? (operator exp) '*)
             (eq? (operator exp) '/)
             (eq? (operator exp) '%)) #t))
      (else #f))))

(define bool-exp?
  (lambda (exp)
    (cond
      ((or (eq? exp 'true)
           (eq? exp 'false)) #t)
      ((and (list? exp)
            (or (eq? (operator exp) '!)
             (eq? (operator exp) '||)
             (eq? (operator exp) '&&)
             (eq? (operator exp) '>)
             (eq? (operator exp) '>=)
             (eq? (operator exp) '<)
             (eq? (operator exp) '<=)
             (eq? (operator exp) '==)
             (eq? (operator exp) '!=))) #t)
      (else #f))))

(define ifthenelse?
  (lambda (stmt)
    (cond
      ((null? stmt) #f)
      (else (and (eq? (operator stmt) 'if)
            (not (null? (cdddr stmt))))))))

(define ifthen?
  (lambda (stmt)
    (cond
      ((null? stmt) #f)
      (else (and (eq? (operator stmt) 'if)
            (null? (cdddr stmt)))))))

; statement checks
(define assignment?
  (lambda (stmt)
    (and (list? stmt) (eq? '= (operator stmt)))))

(define declaration?
  (lambda (stmt)
    (and (null? (cddr stmt)) (eq? (car stmt) 'var))))

(define declarationandassignment?
  (lambda (stmt)
    (and (not (null? (cddr stmt))) (eq? (car stmt) 'var))))

(define return?
  (lambda (stmt)
    (eq? 'return (car stmt))))

(define while?
  (lambda (stmt)
    (eq? 'while (car stmt))))

; negative vs substraction 
(define negative?
  (lambda (exp)
    (and (eq? (operator exp) '-)
         (null? (cddr exp)))))

(define subtraction?
  (lambda (exp)
    (and (eq? (operator exp) '-)
         (not (null? (cddr exp))))))

(define unary?
  (lambda (exp)
    (null? (cddr exp)))) 

; error checks
(define declared?
  (lambda (var s)
    (cond
      ((null? s) #f)
      ((declared-helper? var (car-state-list s)) #t)
      (else
       (declared? var (cdr s))))))

; declared in a state 
(define declared-helper?
  (lambda (var s)
    (cond
      ((null? s) #f)
      ((null? (var-list s)) #f)
      ((eq? (carvar s) var) #t)
      (else (declared-helper? var (cdrstate s))))))

; takes a variable and a state, returns #t if the value of variable is not 'error else #f
(define assigned-helper?
  (lambda (variable s)
    (cond
      ((not (declared-helper? variable s)) #f)
      ((eq? (carvar s) variable)
       (not (eq? (carval s) 'error)))
      (else
       (assigned-helper? variable (cdrstate s))))))

(define assigned?
  (lambda (variable s)
    (cond
      ((null? s) #f)
      ((assigned-helper? variable (car-state-list s)) #t)
      (else
       (assigned? variable (cdr-state-list s))))))

(define block?
  (lambda (stmt)
    (eq? (car stmt) 'begin)))

; our wrappers for bool operations
; our and operator, takes two atoms of 'true or 'false
(define myand
  (lambda (bool1 bool2)
    (and bool1 bool2))) ; convert atom 'true or 'false to #t or #f else run into weird bugs 

; our or operator, takes two atoms of 'true or 'false
(define myor
  (lambda (bool1 bool2)
    (or bool1 bool2)))

; our not operator, takes an atom of 'true or 'false
(define mynot
  (lambda (bool)
    (not bool)))

(define booloperator
  (lambda (op)
    (lambda (bool1 bool2)
      (op bool1 bool2))))

(define atomtobool
  (lambda (atom)
    (cond
      ((eq? atom 'true) #t)
      ((eq? atom 'false) #f)
      (else (error 'InvalidBool)))))

(define noteq
 (lambda (bool1 bool2)
   (not (eq? bool1 bool2))))

; add variable to the first state list in state 
(define add-var-helper
  (lambda (variable value s)
    (cons (cons variable (var-list s)) (cons (cons value (value-list s)) '()))))

(define add-var
  (lambda (variable value s)
    (cons (add-var-helper variable value (car-state-list s)) (cdr-state-list s))))

; remove variable from the first state list in state 
(define remove-var-helper
  (lambda (variable s)
    (cond
      ((null? (var-list s)) s)
      ((eq? (car (var-list s)) variable) (cdrstate s))
      (else
       (add-var-helper (car (var-list s)) (car (value-list s)) (remove-var-helper variable (cdrstate s)))))))

(define remove-var
  (lambda (variable s)
    (cons (remove-var-helper variable (car-state-list s)) (cdr-state-list s))))



; add layer to state each time a new block is entered
(define add-layer
  (lambda (s)
    (cons state-list s)))

(define remove-layer
  (lambda (s)
    (cdr s)))

  