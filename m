Date: Sat, 15 Jul 2000 15:35:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: linux-mm@kvack.org
Subject: [patch] 2.4.0-test4 filemap.c
Message-ID: <Pine.LNX.4.21.0007151534260.17208-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the patch below could make filemap.c better behaved.

this stuff is untested and since I don't really care
about tweaks to the old VM you shouldn't bother me
about it...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- filemap.c.orig	Sat Jul 15 15:31:38 2000
+++ filemap.c	Sat Jul 15 15:33:26 2000
@@ -318,6 +318,14 @@
 			goto cache_unlock_continue;
 
 		/*
+		 * If we *really* have too much memory free in a zone,
+		 * we even won't drop the swap cache memory. We should
+		 * keep this limit high though, because that way balancing
+		 * between zones is faster.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high * 2)
+			goto cache_unlock_continue;
+		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
 		 * were to be marked referenced..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
