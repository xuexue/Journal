#lang racket

(require (planet dmac/spin))
(require web-server/templates)

(define (index req)
  (define logintext "not logged in")
  (include-template "templates/index.html"))

(define (login req)
  (include-template "templates/login.html"))

(define (signup) "This is the signup page")

(define (login-post req)
  (displayln "")
  (displayln (params req 'email))
  (displayln (params req 'password))
  (displayln "")
  "Not implemented")

(get "/" index)
(get "/signup" signup)
(get "/login" login)
(post "/login" login-post)



(run)
