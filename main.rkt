#lang racket

(require
    gregr-misc/maybe
    gregr-misc/record
    net/url
    web-server/dispatch
    web-server/http/cookie
    web-server/http/id-cookie
    web-server/http/redirect
    web-server/http/response-structs
    web-server/http/request-structs
    web-server/http/xexpr
    web-server/templates
    web-server/servlet-env
)

; (define user (get-user (params req 'email) (params req 'password)))

(record user id email)

(define (redir-to place (headers '()))
  (redirect-to place temporarily #:headers headers))

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

(define (response/html htmlstr)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    (list (string->bytes/utf-8 htmlstr))))

(define (index req)
  (define user (get-user-from-cookie req))
  (match user
    ((nothing)
     (response/html
       (include-template "templates/index.html")))
    ((just user)
      (redir-to "/home"))))

(define (home req)
  (response/xexpr
    "You should be logged in"))
;    `(html (body "You should be logged in"))))

(define (login req)
  (response/html
    (include-template "templates/login.html")))

(define (signup req)
  (define user (get-user-from-cookie req))
  (match user
    ((nothing)
     (response/xexpr "TODO"))
    ((just user)
      (redir-to "/home"))))

(define (login-post req)
  (define params
    (match (request-post-data/raw req)
      (#f '())
      (body
        (make-immutable-hash
          (url-query (string->url
                       (string-append "?" (bytes->string/utf-8 body))))))))
  (define email (dict-ref params 'email))
  (define password (dict-ref params 'password))
  (define user (get-user email)) ;todo: check password?
  (match user
    ((nothing)
     (response/html
       (include-template "templates/login.html")))
    ((just user)
      (define new-user-cookie (make-cookie-from-user user))
      (redir-to "/home" (list (cookie->header new-user-cookie))))))

(define (logout req)
  (redir-to "/" (list (cookie->header user-cookie-blank))))

(define-values (site-dispatch site-url)
  (dispatch-rules
    (("") index)
    (("home") home)
    (("signup") signup)
    (("login") #:method "get" login)
    (("login") #:method "post" login-post)
    (("logout") logout)
    ))

(serve/servlet site-dispatch
               #:servlet-path "/"
               #:servlet-regexp #rx""
               #:extra-files-paths
               (list (build-path (current-directory) "static"))
               ;#:command-line? #t
               #:launch-browser? #f
               )
