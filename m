Date: Tue, 8 Aug 2006 09:34:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [2/3] sys_move_pages: Do not fall back to other nodes
In-Reply-To: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608080933510.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

If the user specified a node where we should move the page to then
we really do not want any other node.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/mm/migrate.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/migrate.c	2006-08-08 09:15:29.352637207 -0700
+++ linux-2.6.18-rc3-mm2/mm/migrate.c	2006-08-08 09:25:41.388119893 -0700
@@ -745,7 +745,9 @@ static struct page *new_page_node(struct
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node, GFP_HIGHUSER, 0);
+	return alloc_pages_node(pm->node,
+		GFP_HIGHUSER | __GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY,
+		0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
