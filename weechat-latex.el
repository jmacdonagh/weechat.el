;;; weechat-latex --- Add LateX preview -*- lexical-binding: t -*-

;; Copyright (C) 2013 Rüdiger Sonderfeld <ruediger@c-plusplus.de>

;; Author: Rüdiger Sonderfeld <ruediger@c-plusplus.de>
;;         Moritz Ulrich <moritz@tarn-vedra.de>
;;         Aristid Breitkreuz <aristidb@gmail.com>
;; Keywords: irc chat network weechat
;; URL: https://github.com/the-kenny/weechat.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:
;;
;; The LaTeX preview is based on `org-mode's `org-format-latex'

;;; Code:

(require 'weechat)
(require 'org)

(defgroup weechat-latex nil
  "WeeChat LaTeX preview."
  :link '(url-link "https://github.com/the-kenny/weechat.el")
  :prefix "weechat-latex"
  :group 'weechat)

(defcustom weechat-latex-temp-file-prefix "weechat-latex"
  "Prefix for temporary files."
  :type 'string
  :group 'weechat-latex)

(defcustom weechat-latex-temp-directory-prefix "weechat-latex"
  "Prefix for temporary directory."
  :type 'string
  :group 'weechat-latex)

(defcustom weechat-latex-image-program org-latex-create-formula-image-program
  "Program to convert LaTeX fragments.
See `org-latex-create-formula-image-program'"
  :type '(choice
	  (const :tag "dvipng" dvipng)
	  (const :tag "imagemagick" imagemagick))
  :group 'weechat-latex)

(defvar weechat-latex-temp-dir nil
  "The temporary directory used for preview images.")

(defun weechat-latex--create-preview (at)
  "Wrapper for `org-format-latex'.
The parameter AT should be nil or in (TYPE . POINT) format.  With TYPE being a
string showing the matched LaTeX statement (e.g., ``$'') and POINT being the
POINT to replace.  If AT is nil replace statements everywhere."
  (org-format-latex weechat-latex-temp-file-prefix
                    weechat-latex-temp-dir
                    'overlays
                    "Creating images...%s"
                    at 'forbuffer
                    weechat-latex-image-program))

(defun weechat-latex--set-temp-dir ()
  "Set `weechat-latex-temp-dir' unless it is already set."
  (unless weechat-latex-temp-dir
    (setq weechat-latex-temp-dir
          (make-temp-file weechat-latex-temp-directory-prefix
                          'directory))))

(defun weechat-latex-preview ()
  "Preview LaTeX fragments."
  (interactive)
  (save-excursion
    (let ((inhibit-read-only t))
      (weechat-latex--set-temp-dir)
      (org-remove-latex-fragment-image-overlays)
      (weechat-latex--create-preview nil))))

(defun weechat-latex-preview-region (beg end)
  "Preview LaTeX fragments in region."
  (interactive "r")
  (let* ((math-regex (assoc "$" org-latex-regexps))
         (regex (nth 1 math-regex))
         (n (nth 2 math-regex))
         matches)
    (save-excursion
      (goto-char beg)
      (while (re-search-forward regex end t)
        (setq matches (cons (cons "$" (match-beginning n)) matches)))
      (let ((inhibit-read-only t))
        (weechat-latex--set-temp-dir)
        (dolist (i matches)
          (weechat-latex--create-preview i))))))

(defun weechat-latex-remove ()
  "Remove LaTeX preview images."
  (interactive)
  (let ((inhibit-read-only t))
    (org-remove-latex-fragment-image-overlays)))

(defun weechat-latex-toggle ()
  "Toggle display of LaTeX preview."
  (interactive)
  (if org-latex-fragment-image-overlays
      (weechat-latex-remove)
    (weechat-latex-preview)))

(easy-menu-add-item weechat-mode-menu nil
                    ["Toggle LaTeX Preview" weechat-latex-toggle t]
                    "Toggle Hidden Lines")

(defun weechat-latex-unload-function ()
  "Cleanup WeeChat LaTex module."
  (weechat-latex-remove)
  (easy-menu-remove-item weechat-mode-menu nil "Toggle LaTeX Preview"))

(provide 'weechat-latex)

;;; weechat-latex.el ends here
