Date: Mon, 15 Jan 2001 02:17:31 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: One of those nasty mistakes in pre3 
Message-ID: <Pine.LNX.4.21.0101150212430.12760-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

--- linux.orig/mm/vmscan.c      Mon Jan 15 02:33:15 2001
+++ linux/mm/vmscan.c   Mon Jan 15 02:46:25 2001
@@ -153,7 +153,7 @@

                        if (VALID_PAGE(page) && !PageReserved(page)) {
                                try_to_swap_out(mm, vma, address, pte,
page);
-                               if (--count)
+                               if (!--count)
                                        break;
                        }
                }


  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
