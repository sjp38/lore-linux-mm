Date: Tue, 6 Aug 2002 18:20:32 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] expand_stack upward growing stack & comments
Message-ID: <Pine.LNX.4.44L.0208061818350.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch implements:

- expand_stack for upward growing stacks, thanks to Matthew Wilcox
- trivial: cache file->f_dentry->d_inode; saves a few bytes of compiled
  size. (also by Matthew Wilcox)
- fix the comment in expand_stack that left Matthew puzzled (me)

Please apply for the next kernel,

thank you,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
