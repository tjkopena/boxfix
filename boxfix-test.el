;;; boxfix-test.el --- Tests for boxfix.el -*- lexical-binding: t; -*-

;; Run with: emacs --batch -l boxfix-test.el

(load-file (expand-file-name "boxfix.el" (file-name-directory load-file-name)))

(defvar boxfix-test--pass-count 0)
(defvar boxfix-test--fail-count 0)

(defun boxfix-test--run (input expected label)
  "Run boxfix on INPUT and compare to EXPECTED, reporting LABEL."
  (with-temp-buffer
    (insert input)
    (boxfix (point-min) (point-max))
    (let ((result (buffer-string)))
      (if (string= result expected)
          (progn
            (setq boxfix-test--pass-count (1+ boxfix-test--pass-count))
            (message "  PASS: %s" label))
        (setq boxfix-test--fail-count (1+ boxfix-test--fail-count))
        (message "  FAIL: %s\n    Expected:\n%s\n    Got:\n%s" label expected result)))))

;; --- README examples ---

(boxfix-test--run
 "----------\n| BoxFix |\n----------"
 "┌────────┐\n│ BoxFix │\n└────────┘"
 "Example: simple box")

(boxfix-test--run
 "+-----------------+\n|   Application   |\n-------------------\n| [ TCP ] [ UDP ] |\n|        IP       |\n-------------------\n|  Device Driver  |\n+-----------------+"
 "┌─────────────────┐\n│   Application   │\n├─────────────────┤\n│ [ TCP ] [ UDP ] │\n│        IP       │\n├─────────────────┤\n│  Device Driver  │\n└─────────────────┘"
 "Example: stacked box with T-junctions")

(boxfix-test--run
 "   +\n  +-+\n  | |\n|-----|\n|  +  |\n|     |\n| + + |\n|     |\n| +-+ |\n| | | |\n-------"
 "   ╷\n  ┌┴┐\n  │ │\n┌─┴┬┴─┐\n│  ╵  │\n│     │\n│ ◻ ◻ │\n│     │\n│ ┌─┐ │\n│ │ │ │\n└─┴─┴─┘"
 "Example: nested boxes")

(boxfix-test--run
 "------------+ -------------+\n| Left-Most |-| Right-Most |\n+------------ +-------------"
 "┌───────────┐ ┌────────────┐\n│ Left-Most ├─┤ Right-Most │\n└───────────┘ └────────────┘"
 "Example: adjacent boxes")

(boxfix-test--run
 "  Freedom\n     ^\n     |\n  +--+ Twirling\n  |\n  V\nAlways"
 "  Freedom\n     ▲\n     │\n  ┌──┘ Twirling\n  │\n  ▼\nAlways"
 "Example: arrows")

;; --- Pass 1: character conversions ---

(boxfix-test--run "---" "╶─╴" "Dash to light horizontal")
(boxfix-test--run "###" "╺━╸" "Hash to heavy horizontal")
(boxfix-test--run "===" "═══" "Equals to double horizontal")
(boxfix-test--run "<" "◀" "Less-than to left arrow")
(boxfix-test--run ">" "▶" "Greater-than to right arrow")
(boxfix-test--run "^" "▲" "Caret to up arrow")
(boxfix-test--run "V" "▼" "Capital V to down arrow")
(boxfix-test--run "v" "▼" "Lowercase v to down arrow")

;; --- Pass 1: alphanumeric neighbor guard ---

(boxfix-test--run "x-y" "x-y" "Dash near alpha unchanged")
(boxfix-test--run "1-2" "1-2" "Dash near digits unchanged")
(boxfix-test--run "a#b" "a#b" "Hash near alpha unchanged")
(boxfix-test--run "a=b" "a=b" "Equals near alpha unchanged")
(boxfix-test--run "a+b" "a+b" "Plus near alpha unchanged")
(boxfix-test--run "oven" "oven" "v in word unchanged")
(boxfix-test--run "aVb" "aVb" "V in word unchanged")

;; --- Pass 2: style-aware lookup ---

(boxfix-test--run
 "+----+\n|    |\n+----+"
 "┌────┐\n│    │\n└────┘"
 "Light box with plus corners")

(boxfix-test--run
 "##########\n| BoxFix |\n##########"
 "┍━━━━━━━━┑\n│ BoxFix │\n┕━━━━━━━━┙"
 "Heavy horizontal with light vertical")

(boxfix-test--run
 "==========\n| BoxFix |\n=========="
 "╒════════╕\n│ BoxFix │\n╘════════╛"
 "Double horizontal with light vertical")

(boxfix-test--run
 "==================\n| Fancy BoxFix 1 |\n##################"
 "╒════════════════╕\n│ Fancy BoxFix 1 │\n┕━━━━━━━━━━━━━━━━┙"
 "Example: Fancy BoxFix 1")

(boxfix-test--run
 "==================\n| Fancy BoxFix 2 |\n|################|"
 "╒════════════════╕\n│ Fancy BoxFix 2 │\n┕━━━━━━━━━━━━━━━━┙"
 "Example: Fancy BoxFix 2")

;; --- Summary ---

(message "\n%d passed, %d failed"
         boxfix-test--pass-count boxfix-test--fail-count)
(kill-emacs (if (> boxfix-test--fail-count 0) 1 0))

;;; boxfix-test.el ends here
