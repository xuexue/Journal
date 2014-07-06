#lang racket/base
(provide
  connect-params
  process-emails
  )

(require
  gregr-misc/match
  gregr-misc/record
  net/imap
  racket/list
  )

(record connect-params host port username password mailbox tls?)

(define/destruct (process-emails
                   (connect-params host port username password mailbox tls?)
                   process
                   )
  (parameterize ((imap-port-number port))
    (define-values (conn num-msgs recent-msgs)
      (imap-connect host username password mailbox #:tls? tls?))
    (define (mark-messages-deleted indices)
      (imap-store conn '+ indices (list (symbol->imap-flag 'deleted))))
    (define msg-nums (range 1 (+ 1 num-msgs)))
    (define msgs (imap-get-messages conn msg-nums '(uid header body flags)))
    (let ((result (process mark-messages-deleted (map cons msg-nums msgs))))
      (imap-expunge conn)
      (imap-disconnect conn)
      result)))
