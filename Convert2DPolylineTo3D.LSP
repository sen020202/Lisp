
(vl-load-com)

(defun c:2Dto3D	(/	    ErrorHandles	  SelSet     Counter
		 Len	    eName      eList	  eType	     cError
		 ErrorHandles
		)
  (mapcar 'setvar (list "cmddia" "Cmdecho") (list 0 0))
  (cond
    ((setq SelSet (ssget '((0 . "*Polyline"))))
     (setq Counter 0
	   Len	   (sslength SelSet)
	   Errors 0
     )
     (while (< COunter Len)
       (setq eName (ssname SelSet COunter))
       (cond
	 ((vl-cmdf "Convertpoly" "l" eName "")
	  (setq	eList (entget eName)
		eType (cdr (assoc 100 (member (assoc 8 eList) eList)))
	  )
	  (cond
	    ((= eType "AcDbPolyline")
	     (setq cError (VL-CATCH-ALL-APPLY
			    'lwpTo3d
			    (list (vlax-ename->vla-object eName))
			  )
	     )
	     (if cError
	       (progn
		 (setq errors(1+ errors))
		 (if (not ErrorHandles)
		   (setq ErrorHandles (cdr (assoc 5 eList)))
		   (setq ErrorHandles
			  (strcat ErrorHandles
				  "\n"
				  (cdr (assoc 5 eList))
			  )
		   )
		 )
	       )
	       (entdel eName)
	     )
	    )
	  )
	 )
       )

       (setq Counter (1+ Counter))
       (prompt (strcat "\rProcessing entities "
		       (itoa Counter)
		       " of "
		       (itoa len)
	       )
       )
     )
     (if ErrorHandles
       (progn
	 (setq flname (open "Errors.txt" "w"))
	 (princ	"Could not able to convert Following handle Entities\n"
		flname
	 )
	 (princ ErrorHandles flname)
	 (close flname)
	 (alert (strcat (itoa errors) "of " (itoa len) " Could not able to convert"))
	 (startapp "notepad.exe" "\"Errors.txt\"")
       )
     )
    )
  )
  (princ)
)
(defun c:Z2H ( / ename vla-ent minPointQ maxPointQ)
  (cond
    ((/= (setq eHandle (getstring "Enter Handle: ")) "")
     (setq ename (handent eHandle))
     (setq vla-ent (vlax-ename->vla-object ename))
     (vla-GetBoundingBox vla-ent 'minPoint 'maxPoint)
     (setq minPointQ (vlax-safearray->list minPoint))
     (setq maxPointQ (vlax-safearray->list maxPoint))
     (cond
       ((and minPointQ maxPointQ)
	(vl-cmdf "zoom" "w" minPointQ maxPointQ)
       )
     )
    )
  )
  (princ)
)
(defun lwpTo3d (vbalwp / c1 c2 pts pts3d mydoc myowner my3d ut i lwc)
  (setq	c1 (vlax-variant-value
	     (vla-get-Coordinates vbalwp)
	   )
  )
  (setq c1 (vlax-safearray-get-u-bound c1 1))

  (setq c1 (/ (- c1 1) 2))
  (setq c2 (- (* (+ c1 1) 3) 1))


  (setq	pts (vlax-make-safearray
	      vlax-vbDouble
	      (cons 0 c2)
	    )
  )


  (setq	pts3d (vlax-make-safearray
		vlax-vbDouble
		(cons 0 2)
	      )
  )


  (setq	myDoc (vla-get-Document vbalwp)
  )
  (setq	myowner	(vla-ObjectIdToObject
		  myDoc
		  (vla-get-ownerid vbalwp)
		)
  )
  (setq	my3d (vla-Add3DPoly myowner pts)  )
  (setq	ut (vla-get-Utility mydoc)  )
  (setq i 0)

  (repeat (+ c1 1)
    (setq lwc (vlax-variant-value
		(vla-get-Coordinate vbalwp i)

	      )
    )
    (vlax-safearray-put-element
      pts3d
      0
      (vlax-safearray-get-element lwc 0)
    )
    (vlax-safearray-put-element
      pts3d
      1
      (vlax-safearray-get-element lwc 1)
    )
    (vlax-safearray-put-element
      pts3d
      2
      (vla-get-Elevation vbalwp)
    )


    (setq pts3d	(vlax-variant-value
		  (vla-TranslateCoordinates
		    ut
		    pts3d
		    acOCS
		    acWorld
		    0
		    (vla-get-Normal vbalwp)
		  )
		)

    )
    (vla-put-coordinate my3d i pts3d)
    (setq i (+ i 1))

  )

  (vla-put-layer my3d (vla-get-layer vbalwp))
  (vla-put-Closed my3d (vla-get-Closed vbalwp))
  (vla-put-Color my3d (vla-get-Color vbalwp))
  (vla-put-Linetype my3d (vla-get-Linetype vbalwp))
  (vla-put-LinetypeScale my3d (vla-get-LinetypeScale vbalwp))

  (vla-put-Lineweight my3d (vla-get-Lineweight vbalwp))
  (vla-put-Visible my3d (vla-get-visible vbalwp))
  (vla-Update my3d)
  (vlax-release-object mydoc)
  (vlax-release-object myowner)
  (vlax-release-object ut)
  (vlax-release-object vbalwp)
  (setq my3d my3d)
  NIL

)