;;; weechat-smiley --- Display smiley faces ;; -*- lexical-binding: t -*-

;; Copyright (C) 2013 Rüdiger Sonderfeld <ruediger@c-plusplus.de>

;; Author: Rüdiger Sonderfeld <ruediger@c-plusplus.de>
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
;; This module uses `smiley-region' from Gnus smiley.el.

;; To support short smileys (without nose) use:
;;
;; (setq smiley-regexp-alist
;;   '(("\\(;-?)\\)\\W" 1 "blink")
;;     ("[^;]\\(;)\\)\\W" 1 "blink")
;;     ("\\(:-?]\\)\\W" 1 "forced")
;;     ("\\(8-?)\\)\\W" 1 "braindamaged")
;;     ("\\(:-?|\\)\\W" 1 "indifferent")
;;     ("\\(:-?[/\\]\\)\\W" 1 "wry")
;;     ("\\(:-?(\\)\\W" 1 "sad")
;;     ("\\(X-?)\\)\\W" 1 "dead")
;;     ("\\(:-?{\\)\\W" 1 "frown")
;;     ("\\(>:-?)\\)\\W" 1 "evil")
;;     ("\\(;-?(\\)\\W" 1 "cry")
;;     ("\\(:-?D\\)\\W" 1 "grin")
;;     ;; "smile" must be come after "evil"
;;     ("\\(\\^?:-?)\\)\\W" 1 "smile")))

;;; Code:

(defun weechat-smiley-buffer ()
  "Smiley the region."
  (let ((inhibit-read-only t))
    (smiley-buffer)))

(defun weechat-smiley--do ()
  "Hook for weechat."
  (save-excursion
    (let ((inhibit-read-only t))
      (smiley-region (+ (point-min) weechat-text-column) (point-max)))))

(weechat-do-buffers (weechat-smiley-buffer))
(add-hook 'weechat-insert-modify-hook #'weechat-smiley--do)

(defun weechat-smiley-unload-function ()
  "Remove smileys from buffer."
  (let ((inhibit-read-only t))
    (weechat-do-buffers (smiley-toggle-buffer -1))))

(provide 'weechat-smiley)

;;; weechat-smiley.el ends here
