From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 7/4  -ac to newer rmap
Message-Id: <20021113145002Z80262-18062+21@imladris.surriel.com>
Date: Wed, 13 Nov 2002 12:50:01 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I guess that after a truncate() and maybe some special ext3 transactions
anonymous pages can have page->buffers set. Not quite sure about delete
from swap cache, though ... maybe the reverse of this patch should be
applied into the -rmap tree and mainline instead ?

(ObWork: my patches are sponsored by Conectiva, Inc)

--- linux-2.4.19/mm/swap_state.c	2002-11-13 08:48:32.000000000 -0200
+++ linux-2.4-rmap/mm/swap_state.c	2002-11-13 12:10:46.000000000 -0200
@@ -151,8 +151,7 @@
 	if (!PageLocked(page))
 		BUG();
 
-	if (unlikely(!block_flushpage(page, 0)))
-		PAGE_BUG(page);	/* an anonymous page cannot have page->buffers set */
+	block_flushpage(page, 0);
 
 	entry.val = page->index;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
