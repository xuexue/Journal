#lang racket

(require
    (planet dmac/spin)
    gregr-misc/maybe
    gregr-misc/record
    web-server/http/cookie
    web-server/http/id-cookie
    web-server/templates
)

; (define user (get-user (params req 'email) (params req 'password)))

(record user id email)

(define (redir-to place (headers '()))
  (define location (header #"Location" place))
  `(302 ,(cons location headers) "Redirecting."))

(define (get-user email)
    (if (eq? email #f)
      (nothing)
      (just (user 1234 email)))) ; this is suppose to be a db call

(define user-cookie-name "usercookiething")
(define user-cookie-salt #"Blah")
(define user-cookie-blank (logout-id-cookie user-cookie-name))

(define (make-cookie-from-user user)
  (define email (user-email user))
  (displayln email)
  (make-id-cookie user-cookie-name user-cookie-salt email))

(define (get-user-from-cookie req)
  (define email (request-id-cookie user-cookie-name user-cookie-salt req))
  (displayln email)
  (get-user email))

(define (index req)
  (define user (get-user-from-cookie req))
  (match user
    ((nothing)
      (define logintext "not logged in")
      (include-template "templates/index.html"))
    ((just user)
      (redir-to #"/home"))))

(define (login req)
  (include-template "templates/login.html"))

(define (home) "You should be logged in")

(define (signup req)
  (define user (get-user-from-cookie req))
  (match user
    ((nothing)
      "TODO")
    ((just user)
      (redir-to #"/home"))))

(define (login-post req)
  (define email (params req 'email))
  (define password (params req 'password))
  (define user (get-user email)) ;todo: check password?
  (match user
    ((nothing)
      (include-template "templates/login.html"))
    ((just user)
      (define new-user-cookie (make-cookie-from-user user))
      (redir-to #"/home" (list (cookie->header new-user-cookie))))))

(define (logout req)
  (redir-to #"/" (list (cookie->header user-cookie-blank))))

(get "/" index)
(get "/signup" signup)
(get "/login" login)
(post "/login" login-post)
(get "/home" home)
(get "/logout" logout)

(run)
