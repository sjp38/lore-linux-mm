Received: (from jmm@localhost)
	by bp6.sublogic.lan (8.9.3/8.9.3) id CAA02249
	for linux-mm@kvack.org; Tue, 20 Jun 2000 02:27:52 -0400
Date: Tue, 20 Jun 2000 02:27:52 -0400
From: James Manning <jmm@computer.org>
Subject: redundant BAD_RANGE check?
Message-ID: <20000620022752.A2246@bp6.sublogic.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii

Given that expand() appears to do its own BAD_RANGE check, it looks
unnecessary to check it again in rmqueue.

James

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bad_range.diff"

--- linux-2.4.0-test1-ac22/mm/page_alloc.c.orig	Tue Jun 20 02:24:20 2000
+++ linux-2.4.0-test1-ac22/mm/page_alloc.c	Tue Jun 20 02:25:42 2000
@@ -203,8 +203,6 @@
 			spin_unlock_irqrestore(&zone->lock, flags);
 
 			set_page_count(page, 1);
-			if (BAD_RANGE(zone,page))
-				BUG();
 			return page;	
 		}
 		curr_order++;

--MGYHOYXEY6WxJCY8--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
