(in-package :example)

(defun symb (a b)
  (intern (format nil "~a-~a" (symbol-name a) (symbol-name b))))

(defmacro defmodel (name slot-definitions)
  `(progn
     (defclass ,name ()
       ((id :col-type serial :reader ,(symb name 'id))
	,@slot-definitions)		      
       (:metaclass dao-class)
       (:keys id))
     (defun ,(symb name 'init-table) ()
         (with-connection (db-params)
	   (when (table-exists-p ',name)
	     (query (conc "DROP TABLE" (string ',name))))
	   (execute (dao-table-definition ',name))))
     ;; Create
     (defmacro ,(symb name 'create) (&rest args)
       `(with-connection (db-params)
	  (make-dao ',',name ,@args)))
     ;; Read
     (defun ,(symb name 'get-all) ()
       (with-connection (db-params)
	 (select-dao ',name)))
     (defun ,(symb name 'get) (id)
       (with-connection (db-params)
	 (get-dao ',name id)))
     (defmacro ,(symb name 'select) (sql-test &optional sort)
       `(with-connection (db-params)
	  (select-dao ',',name ,sql-test ,sort)))
     ;; Update
     (defun ,(symb name 'update) (,name)
       (with-connection (db-params)
	 (update-dao ,name)))
     ;; Delete
     (defun ,(symb name 'delete) (,name)
       (with-connection (db-params)
	 (delete-dao ,name)))))             