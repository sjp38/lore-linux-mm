Date: Sun, 14 Jan 2001 11:57:29 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Locking issue on try_to_swap_out()
Message-ID: <Pine.LNX.4.21.0101141154290.12327-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

In theory, there is nothing which guarantees that nobody will mess with
the page between "UnlockPage" and "deactivate_page" (that is pretty hard
to happen, I suppose, but anyway)

--- mm/vmscan.c.orig       Sun Jan 14 13:23:55 2001
+++ mm/vmscan.c    Sun Jan 14 13:24:16 2001
@@ -72,10 +72,10 @@
                swap_duplicate(entry);
                set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
-               UnlockPage(page);
                mm->rss--;
                if (!page->age)
                        deactivate_page(page);
+               UnlockPage(page);
                page_cache_release(page);
                return;
        }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
