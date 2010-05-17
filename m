Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 56E986002CC
	for <linux-mm@kvack.org>; Mon, 17 May 2010 17:07:03 -0400 (EDT)
Subject: [PATCH] add numa_random() stub for non-NUMA build
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Mon, 17 May 2010 17:06:49 -0400
Message-Id: <1274130409.24007.138.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>
Cc: Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

Against 2.6.34-rc7-mmotm-100514-1333:

Define stub numa_random() for !NUMA configuration.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/nodemask.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6.34-rc7-mmotm-100514-1333/include/linux/nodemask.h
===================================================================
--- linux-2.6.34-rc7-mmotm-100514-1333.orig/include/linux/nodemask.h	2010-05-17 08:40:39.000000000 -0400
+++ linux-2.6.34-rc7-mmotm-100514-1333/include/linux/nodemask.h	2010-05-17 16:37:18.000000000 -0400
@@ -269,9 +269,6 @@ static inline int __first_unset_node(con
 			find_first_zero_bit(maskp->bits, MAX_NUMNODES));
 }
 
-#define node_random(mask) __node_random(&(mask))
-extern int __node_random(const nodemask_t *maskp);
-
 #define NODE_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(MAX_NUMNODES)
 
 #if MAX_NUMNODES <= BITS_PER_LONG
@@ -435,6 +432,10 @@ static inline void node_set_offline(int 
 	node_clear_state(nid, N_ONLINE);
 	nr_online_nodes = num_node_state(N_ONLINE);
 }
+
+#define node_random(mask) __node_random(&(mask))
+extern int __node_random(const nodemask_t *maskp);
+
 #else
 
 static inline int node_state(int node, enum node_states state)
@@ -465,6 +466,8 @@ static inline int num_node_state(enum no
 
 #define node_set_online(node)	   node_set_state((node), N_ONLINE)
 #define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
+
+static inline int node_random(const nodemask_t mask) { return 0; }
 #endif
 
 #define node_online_map 	node_states[N_ONLINE]


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
