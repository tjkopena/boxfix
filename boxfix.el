;;; boxfix.el --- Fix up ASCII box art with Unicode box-drawing characters -*- lexical-binding: t; -*-

;; Style encoding: 0=nil, 1=light, 2=heavy, 3=double

(defconst boxfix--mapping-vector
  (vector
   nil ?╴ ?╸ ?═ ?╷ ?┐ ?┑ ?╕ ?╻ ?┒ ?┓ ?┓ ?║ ?╖ ?┓ ?╗
   ?╶ ?─ ?╾ ?─ ?┌ ?┬ ?┭ ?┬ ?┎ ?┰ ?┱ ?┬ ?╓ ?╥ ?┬ ?╦
   ?╺ ?╼ ?━ ?━ ?┍ ?┮ ?┯ ?┬ ?┏ ?┲ ?┳ ?┳ ?┏ ?┬ ?┳ ?╦
   ?═ ?─ ?━ ?═ ?╒ ?┬ ?┬ ?╤ ?┏ ?┬ ?┳ ?╦ ?╔ ?╦ ?╦ ?╦
   ?╵ ?┘ ?┙ ?╛ ?│ ?┤ ?┥ ?╡ ?╽ ?┧ ?┪ ?┤ ?│ ?┤ ?┤ ?╣
   ?└ ?┴ ?┵ ?┴ ?├ ?┼ ?┽ ?┼ ?┟ ?╁ ?╅ ?┼ ?├ ?┼ ?┼ ?┼
   ?┕ ?┶ ?┷ ?┴ ?┝ ?┾ ?┿ ?┼ ?┢ ?╆ ?╈ ?┼ ?├ ?┼ ?┼ ?┼
   ?╘ ?┴ ?┴ ?╧ ?╞ ?┼ ?┼ ?╪ ?├ ?┼ ?┼ ?┼ ?╠ ?┼ ?┼ ?╬
   ?╹ ?┚ ?┛ ?┛ ?╿ ?┦ ?┩ ?┤ ?┃ ?┨ ?┫ ?┫ ?┃ ?┤ ?┫ ?╣
   ?┖ ?┸ ?┹ ?┴ ?┞ ?╀ ?╃ ?┼ ?┠ ?╂ ?╉ ?┼ ?├ ?┼ ?┼ ?┼
   ?┗ ?┺ ?┻ ?┻ ?┡ ?╄ ?╇ ?┼ ?┣ ?╊ ?╋ ?╋ ?┣ ?┼ ?╋ ?╋
   ?┗ ?┴ ?┻ ?╩ ?├ ?┼ ?┼ ?┼ ?┣ ?┼ ?╋ ?╋ ?╠ ?┼ ?╋ ?╬
   ?║ ?╜ ?┛ ?╝ ?│ ?┤ ?┤ ?╣ ?┃ ?┤ ?┫ ?╣ ?║ ?╢ ?╣ ?╣
   ?╙ ?╨ ?┴ ?╩ ?├ ?┼ ?┼ ?┼ ?├ ?┼ ?┼ ?┼ ?╟ ?╫ ?┼ ?╬
   ?┗ ?┴ ?┻ ?╩ ?├ ?┼ ?┼ ?┼ ?┣ ?┼ ?╋ ?╋ ?╠ ?┼ ?╋ ?╬
   ?╚ ?╩ ?╩ ?╩ ?╠ ?┼ ?┼ ?╬ ?╠ ?┼ ?╋ ?╬ ?╠ ?╬ ?╬ ?╬)
  "Map from style-tuple index to Unicode box-drawing character.
Index = up*64 + right*16 + down*4 + left.
Style encoding: 0=nil, 1=light, 2=heavy, 3=double.")

(defconst boxfix--char-style
  (let ((ht (make-hash-table)))
    ;; Drawing characters from palette
    (puthash ?─ 1 ht) (puthash ?━ 2 ht) (puthash ?│ 1 ht) (puthash ?┃ 2 ht)
    (puthash ?┌ 1 ht) (puthash ?┍ 1 ht) (puthash ?┎ 1 ht) (puthash ?┏ 2 ht)
    (puthash ?┐ 1 ht) (puthash ?┑ 1 ht) (puthash ?┒ 1 ht) (puthash ?┓ 2 ht)
    (puthash ?└ 1 ht) (puthash ?┕ 1 ht) (puthash ?┖ 1 ht) (puthash ?┗ 2 ht)
    (puthash ?┘ 1 ht) (puthash ?┙ 1 ht) (puthash ?┚ 1 ht) (puthash ?┛ 2 ht)
    (puthash ?├ 1 ht) (puthash ?┝ 1 ht) (puthash ?┞ 1 ht) (puthash ?┟ 1 ht)
    (puthash ?┠ 2 ht) (puthash ?┡ 2 ht) (puthash ?┢ 2 ht) (puthash ?┣ 2 ht)
    (puthash ?┤ 1 ht) (puthash ?┥ 1 ht) (puthash ?┦ 1 ht) (puthash ?┧ 1 ht)
    (puthash ?┨ 2 ht) (puthash ?┩ 2 ht) (puthash ?┪ 2 ht) (puthash ?┫ 2 ht)
    (puthash ?┬ 1 ht) (puthash ?┭ 1 ht) (puthash ?┮ 1 ht) (puthash ?┯ 2 ht)
    (puthash ?┰ 1 ht) (puthash ?┱ 2 ht) (puthash ?┲ 2 ht) (puthash ?┳ 2 ht)
    (puthash ?┴ 1 ht) (puthash ?┵ 1 ht) (puthash ?┶ 1 ht) (puthash ?┷ 2 ht)
    (puthash ?┸ 1 ht) (puthash ?┹ 2 ht) (puthash ?┺ 2 ht) (puthash ?┻ 2 ht)
    (puthash ?┼ 1 ht) (puthash ?┽ 1 ht) (puthash ?┾ 1 ht) (puthash ?┿ 1 ht)
    (puthash ?╀ 1 ht) (puthash ?╁ 1 ht) (puthash ?╂ 1 ht) (puthash ?╃ 1 ht)
    (puthash ?╄ 1 ht) (puthash ?╅ 1 ht) (puthash ?╆ 1 ht) (puthash ?╇ 2 ht)
    (puthash ?╈ 2 ht) (puthash ?╉ 2 ht) (puthash ?╊ 2 ht) (puthash ?╋ 2 ht)
    (puthash ?═ 3 ht) (puthash ?║ 3 ht)
    (puthash ?╒ 1 ht) (puthash ?╓ 1 ht) (puthash ?╔ 3 ht)
    (puthash ?╕ 1 ht) (puthash ?╖ 1 ht) (puthash ?╗ 3 ht)
    (puthash ?╘ 1 ht) (puthash ?╙ 1 ht) (puthash ?╚ 3 ht)
    (puthash ?╛ 1 ht) (puthash ?╜ 1 ht) (puthash ?╝ 3 ht)
    (puthash ?╞ 1 ht) (puthash ?╟ 3 ht) (puthash ?╠ 3 ht)
    (puthash ?╡ 1 ht) (puthash ?╢ 3 ht) (puthash ?╣ 3 ht)
    (puthash ?╤ 3 ht) (puthash ?╥ 1 ht) (puthash ?╦ 3 ht)
    (puthash ?╧ 3 ht) (puthash ?╨ 1 ht) (puthash ?╩ 3 ht)
    (puthash ?╪ 1 ht) (puthash ?╫ 1 ht) (puthash ?╬ 3 ht)
    (puthash ?╴ 1 ht) (puthash ?╵ 1 ht) (puthash ?╶ 1 ht) (puthash ?╷ 1 ht)
    (puthash ?╸ 2 ht) (puthash ?╹ 2 ht) (puthash ?╺ 2 ht) (puthash ?╻ 2 ht)
    (puthash ?╼ 1 ht) (puthash ?╽ 1 ht) (puthash ?╾ 1 ht) (puthash ?╿ 1 ht)
    ;; Box characters
    (puthash ?◻ 1 ht) (puthash ?◼ 2 ht) (puthash ?▣ 3 ht)
    ht)
  "Map from drawing/box character to base style (1=light, 2=heavy, 3=double).")

(defconst boxfix--box-chars
  '((1 . ?◻) (2 . ?◼) (3 . ?▣))
  "Map from style number to box character.")

(defconst boxfix--arrow-chars
  '(?▶ ?◀ ?▲ ?▼)
  "Unicode arrow characters.")

(defconst boxfix--char-directions
  (let ((ht (make-hash-table)))
    ;; Each entry: [up right down left] with 0=nil, 1=light, 2=heavy, 3=double
    (puthash ?─ [0 1 0 1] ht) (puthash ?━ [0 2 0 2] ht)
    (puthash ?│ [1 0 1 0] ht) (puthash ?┃ [2 0 2 0] ht)
    (puthash ?┌ [0 1 1 0] ht) (puthash ?┍ [0 2 1 0] ht)
    (puthash ?┎ [0 1 2 0] ht) (puthash ?┏ [0 2 2 0] ht)
    (puthash ?┐ [0 0 1 1] ht) (puthash ?┑ [0 0 1 2] ht)
    (puthash ?┒ [0 0 2 1] ht) (puthash ?┓ [0 0 2 2] ht)
    (puthash ?└ [1 1 0 0] ht) (puthash ?┕ [1 2 0 0] ht)
    (puthash ?┖ [2 1 0 0] ht) (puthash ?┗ [2 2 0 0] ht)
    (puthash ?┘ [1 0 0 1] ht) (puthash ?┙ [1 0 0 2] ht)
    (puthash ?┚ [2 0 0 1] ht) (puthash ?┛ [2 0 0 2] ht)
    (puthash ?├ [1 1 1 0] ht) (puthash ?┝ [1 2 1 0] ht)
    (puthash ?┞ [2 1 1 0] ht) (puthash ?┟ [1 1 2 0] ht)
    (puthash ?┠ [2 1 2 0] ht) (puthash ?┡ [2 2 1 0] ht)
    (puthash ?┢ [1 2 2 0] ht) (puthash ?┣ [2 2 2 0] ht)
    (puthash ?┤ [1 0 1 1] ht) (puthash ?┥ [1 0 1 2] ht)
    (puthash ?┦ [2 0 1 1] ht) (puthash ?┧ [1 0 2 1] ht)
    (puthash ?┨ [2 0 2 1] ht) (puthash ?┩ [2 0 1 2] ht)
    (puthash ?┪ [1 0 2 2] ht) (puthash ?┫ [2 0 2 2] ht)
    (puthash ?┬ [0 1 1 1] ht) (puthash ?┭ [0 1 1 2] ht)
    (puthash ?┮ [0 2 1 1] ht) (puthash ?┯ [0 2 1 2] ht)
    (puthash ?┰ [0 1 2 1] ht) (puthash ?┱ [0 1 2 2] ht)
    (puthash ?┲ [0 2 2 1] ht) (puthash ?┳ [0 2 2 2] ht)
    (puthash ?┴ [1 1 0 1] ht) (puthash ?┵ [1 1 0 2] ht)
    (puthash ?┶ [1 2 0 1] ht) (puthash ?┷ [1 2 0 2] ht)
    (puthash ?┸ [2 1 0 1] ht) (puthash ?┹ [2 1 0 2] ht)
    (puthash ?┺ [2 2 0 1] ht) (puthash ?┻ [2 2 0 2] ht)
    (puthash ?┼ [1 1 1 1] ht) (puthash ?┽ [1 1 1 2] ht)
    (puthash ?┾ [1 2 1 1] ht) (puthash ?┿ [1 2 1 2] ht)
    (puthash ?╀ [2 1 1 1] ht) (puthash ?╁ [1 1 2 1] ht)
    (puthash ?╂ [2 1 2 1] ht) (puthash ?╃ [2 1 1 2] ht)
    (puthash ?╄ [2 2 1 1] ht) (puthash ?╅ [1 1 2 2] ht)
    (puthash ?╆ [1 2 2 1] ht) (puthash ?╇ [2 2 1 2] ht)
    (puthash ?╈ [1 2 2 2] ht) (puthash ?╉ [2 1 2 2] ht)
    (puthash ?╊ [2 2 2 1] ht) (puthash ?╋ [2 2 2 2] ht)
    (puthash ?═ [0 3 0 3] ht) (puthash ?║ [3 0 3 0] ht)
    (puthash ?╒ [0 3 1 0] ht) (puthash ?╓ [0 1 3 0] ht) (puthash ?╔ [0 3 3 0] ht)
    (puthash ?╕ [0 0 1 3] ht) (puthash ?╖ [0 0 3 1] ht) (puthash ?╗ [0 0 3 3] ht)
    (puthash ?╘ [1 3 0 0] ht) (puthash ?╙ [3 1 0 0] ht) (puthash ?╚ [3 3 0 0] ht)
    (puthash ?╛ [1 0 0 3] ht) (puthash ?╜ [3 0 0 1] ht) (puthash ?╝ [3 0 0 3] ht)
    (puthash ?╞ [1 3 1 0] ht) (puthash ?╟ [3 1 3 0] ht) (puthash ?╠ [3 3 3 0] ht)
    (puthash ?╡ [1 0 1 3] ht) (puthash ?╢ [3 0 3 1] ht) (puthash ?╣ [3 0 3 3] ht)
    (puthash ?╤ [0 3 1 3] ht) (puthash ?╥ [0 1 3 1] ht) (puthash ?╦ [0 3 3 3] ht)
    (puthash ?╧ [1 3 0 3] ht) (puthash ?╨ [3 1 0 1] ht) (puthash ?╩ [3 3 0 3] ht)
    (puthash ?╪ [1 3 1 3] ht) (puthash ?╫ [3 1 3 1] ht) (puthash ?╬ [3 3 3 3] ht)
    (puthash ?╴ [0 0 0 1] ht) (puthash ?╵ [1 0 0 0] ht)
    (puthash ?╶ [0 1 0 0] ht) (puthash ?╷ [0 0 1 0] ht)
    (puthash ?╸ [0 0 0 2] ht) (puthash ?╹ [2 0 0 0] ht)
    (puthash ?╺ [0 2 0 0] ht) (puthash ?╻ [0 0 2 0] ht)
    (puthash ?╼ [0 2 0 1] ht) (puthash ?╽ [1 0 2 0] ht)
    (puthash ?╾ [0 1 0 2] ht) (puthash ?╿ [2 0 1 0] ht)
    ;; Box characters: all directions nil
    (puthash ?◻ [0 0 0 0] ht) (puthash ?◼ [0 0 0 0] ht) (puthash ?▣ [0 0 0 0] ht)
    ht)
  "Map from drawing/box character to direction style vector [up right down left].
Style encoding: 0=nil, 1=light, 2=heavy, 3=double.")

(defconst boxfix--opposite-direction [2 3 0 1]
  "Map from direction index to opposite direction.
Directions: 0=up, 1=right, 2=down, 3=left.")

(defun boxfix--neighbor-style (char direction base-style)
  "Return (STYLE . USED-FALLBACK) for adjacent CHAR in DIRECTION.
DIRECTION: 0=up, 1=right, 2=down, 3=left.
STYLE is the style contribution.  USED-FALLBACK is non-nil when the
adjacent drawing/box character had a nil component in the direction of
cursor and the character's base style was used as a fallback."
  (cond
   ((null char) '(0))
   ((memq char boxfix--arrow-chars) (cons base-style nil))
   (t
    (let ((dirs (gethash char boxfix--char-directions)))
      (if dirs
          (let ((component (aref dirs (aref boxfix--opposite-direction direction))))
            (if (= component 0)
                (cons (gethash char boxfix--char-style 0) t)
              (cons component nil)))
        '(0))))))

(defun boxfix--alnum-neighbor-p (pos)
  "Return non-nil if the character to the left or right of POS is alphanumeric."
  (or (let ((left (char-before pos)))
        (and left (or (and (>= left ?a) (<= left ?z))
                      (and (>= left ?A) (<= left ?Z))
                      (and (>= left ?0) (<= left ?9)))))
      (let ((right (char-after (1+ pos))))
        (and right (or (and (>= right ?a) (<= right ?z))
                       (and (>= right ?A) (<= right ?Z))
                       (and (>= right ?0) (<= right ?9)))))))

(defun boxfix--char-above (pos)
  "Return the character at the same column on the line above POS, or nil."
  (save-excursion
    (goto-char pos)
    (let ((col (current-column))
          (orig-bol (line-beginning-position)))
      (when (= (forward-line -1) 0)
        (when (/= (line-beginning-position) orig-bol)
          (move-to-column col)
          (when (= (current-column) col)
            (char-after (point))))))))

(defun boxfix--char-below (pos)
  "Return the character at the same column on the line below POS, or nil."
  (save-excursion
    (goto-char pos)
    (let ((col (current-column))
          (orig-bol (line-beginning-position)))
      (when (= (forward-line 1) 0)
        (when (/= (line-beginning-position) orig-bol)
          (move-to-column col)
          (when (= (current-column) col)
            (char-after (point))))))))

(defun boxfix (beg end)
  "Fix up ASCII box art in the region between BEG and END.
Converts |, -, +, <, >, ^, v/V to Unicode drawing characters, then
adjusts each drawing/box character based on neighbor styles.
Respects `rectangle-mark-mode' when active."
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (message "Select region for boxfix, then press C-M-c to confirm.")
     (recursive-edit)
     (unless (use-region-p)
       (user-error "No region selected"))
     (list (region-beginning) (region-end))))
  (let ((segments (if (bound-and-true-p rectangle-mark-mode)
                      (extract-rectangle-bounds beg end)
                    (list (cons beg end)))))
    (save-excursion
      ;; Pass 1: Convert ASCII characters to drawing/box/arrow characters.
      (dolist (seg segments)
        (goto-char (car seg))
        (while (< (point) (cdr seg))
          (let ((ch (char-after (point))))
            (cond
             ((= ch ?|)
              (delete-char 1)
              (insert-char ?│))
             ((and (= ch ?-) (not (boxfix--alnum-neighbor-p (point))))
              (delete-char 1)
              (insert-char ?─))
             ((and (= ch ?#) (not (boxfix--alnum-neighbor-p (point))))
              (delete-char 1)
              (insert-char ?━))
             ((and (= ch ?=) (not (boxfix--alnum-neighbor-p (point))))
              (delete-char 1)
              (insert-char ?═))
             ((and (= ch ?+) (not (boxfix--alnum-neighbor-p (point))))
              (delete-char 1)
              (insert-char ?◻))
             ((= ch ?<)
              (delete-char 1)
              (insert-char ?◀))
             ((= ch ?>)
              (delete-char 1)
              (insert-char ?▶))
             ((= ch ?^)
              (delete-char 1)
              (insert-char ?▲))
             ((and (or (= ch ?v) (= ch ?V))
                   (not (boxfix--alnum-neighbor-p (point))))
              (delete-char 1)
              (insert-char ?▼))
             (t (forward-char 1))))))
      ;; Pass 2: Style-aware replacement of drawing and box characters.
      ;; Uses deferred processing with fallback deferral: characters
      ;; whose key requires a nil-fallback are deferred until all
      ;; non-fallback characters stabilize, avoiding oscillation from
      ;; order-dependent fallback guesses.  Cycle detection stops
      ;; processing if the buffer state repeats.
      (let ((progress t)
            (seen-states (make-hash-table :test 'equal)))
        (puthash (buffer-string) t seen-states)
        (while progress
          (setq progress nil)
          (let (non-fallback-repls fallback-repls)
            (dolist (seg segments)
              (goto-char (car seg))
              (while (< (point) (cdr seg))
                (let* ((ch (char-after (point)))
                       (base (gethash ch boxfix--char-style)))
                  (when base
                    (let* ((pos (point))
                           (above (boxfix--char-above pos))
                           (right-char (char-after (1+ pos)))
                           (below (boxfix--char-below pos))
                           (left-char (char-before pos))
                           (up-r (boxfix--neighbor-style above 0 base))
                           (rt-r (boxfix--neighbor-style right-char 1 base))
                           (dn-r (boxfix--neighbor-style below 2 base))
                           (lt-r (boxfix--neighbor-style left-char 3 base))
                           (up-s (car up-r)) (rt-s (car rt-r))
                           (dn-s (car dn-r)) (lt-s (car lt-r))
                           (used-fallback (or (cdr up-r) (cdr rt-r)
                                              (cdr dn-r) (cdr lt-r)))
                           (idx (+ (* up-s 64) (* rt-s 16) (* dn-s 4) lt-s))
                           (new-char
                            (if (= idx 0)
                                (cdr (assq base boxfix--box-chars))
                              (aref boxfix--mapping-vector idx))))
                      ;; Fallback per spec II.4b: if the result is a
                      ;; same-axis transition character or has lost all
                      ;; directional components of cursor's base style,
                      ;; treat as "no entry" and re-lookup with all
                      ;; non-nil components set to cursor's base style.
                      (when (and new-char
                                 (or (memq new-char '(?╼ ?╽ ?╾ ?╿))
                                     (let ((new-base (gethash new-char boxfix--char-style 0)))
                                       (and (/= new-base base)
                                            (let ((nd (gethash new-char boxfix--char-directions)))
                                              (and nd
                                                   (/= (aref nd 0) base)
                                                   (/= (aref nd 1) base)
                                                   (/= (aref nd 2) base)
                                                   (/= (aref nd 3) base)))))))
                        (let* ((fb-idx (+ (* (if (> up-s 0) base 0) 64)
                                          (* (if (> rt-s 0) base 0) 16)
                                          (* (if (> dn-s 0) base 0) 4)
                                          (if (> lt-s 0) base 0))))
                          (setq new-char
                                (if (= fb-idx 0)
                                    (cdr (assq base boxfix--box-chars))
                                  (aref boxfix--mapping-vector fb-idx)))))
                      (when (and new-char (/= ch new-char))
                        (if used-fallback
                            (push (cons pos new-char) fallback-repls)
                          (push (cons pos new-char) non-fallback-repls))))))
                (forward-char 1)))
            ;; Prefer non-fallback replacements; use fallback only when stuck.
            (let ((repls (or non-fallback-repls fallback-repls)))
              (when repls
                (dolist (r repls)
                  (goto-char (car r))
                  (delete-char 1)
                  (insert-char (cdr r)))
                ;; Cycle detection: stop if this state was seen before.
                (let ((state (buffer-string)))
                  (unless (gethash state seen-states)
                    (puthash state t seen-states)
                    (setq progress t)))))))))))

(provide 'boxfix)
;;; boxfix.el ends here
