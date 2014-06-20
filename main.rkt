#lang racket

(require
    (planet dmac/spin)
    gregr-misc/maybe
    gregr-misc/record
    web-server/http/id-cookie
    web-server/templates
)

; (define user (get-user (params req 'email) (params req 'password)))

(record user id email passwd)

(define (redir-to place)
  (define h (list (header #"Location" place)))
  `(302 ,h "Redirecting."))

(define (get-user email passwd)
    (just (user 1234 email passwd))) ; this is suppose to be a db call

(define (index req)
  (define logintext "not logged in")
  (include-template "templates/index.html"))

(define (login req)
  (include-template "templates/login.html"))

(define (home) "You should be logged in")

(define (signup)
  (redir-to #"/home"))

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
(get "/home" home)

(run)
