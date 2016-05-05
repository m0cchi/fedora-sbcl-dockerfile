# Swank Server

## build
```bash
docker build -f fedora-sbcl.dockerfile -t fedora-sbcl .
```

## run
```bash
docker run -d -p 54005:4005 fedora-sbcl
```

## connect
```common-lisp
(ql:quickload :swank-client)
(swank-client:with-slime-connection (con "localhost" 54005)
                                    (swank-client:slime-eval '(defun foo () "foo") con))
```