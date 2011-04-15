Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B04D900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:48:33 -0400 (EDT)
Message-Id: <20110415194830.256999587@linux.com>
Date: Fri, 15 Apr 2011 14:48:12 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup6 1/5] slub: Use NUMA_NO_NODE in get_partial
References: <20110415194811.810587216@linux.com>
Content-Disposition: inline; filename=use_numa_nonode
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

A -1 was leftover during the conversion.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 14:27:58.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 14:28:18.000000000 -0500
@@ -1487,7 +1487,7 @@ static struct page *get_partial(struct k
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
 	page = get_partial_node(get_node(s, searchnode));
-	if (page || node != -1)
+	if (page || node != NUMA_NO_NODE)
 		return page;
 
 	return get_any_partial(s, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
