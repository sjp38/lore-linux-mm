Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3094D6B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 00:26:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I5QiWp014894
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 14:26:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C2D745DE4F
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 14:26:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EEBE45DD6E
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 14:26:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B6E8E38008
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 14:26:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB266E38006
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 14:26:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [cleanup][PATCH] Fix indentation of the comments of do_migrate_pages
Message-Id: <20100118142507.AE4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Jan 2010 14:26:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Currently, do_migrate_pages() have very long comment and this is
not indent properly. I often misunderstand it is function starting
commnents and confused it.

this patch fixes it.

note: this patch doesn't break 80 column rule. I guess original
      author intended this indentaion, but an accident corrupted it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   60 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9751f3f..e5bb7fb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -887,36 +887,36 @@ int do_migrate_pages(struct mm_struct *mm,
 	if (err)
 		goto out;
 
-/*
- * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
- * bit in 'to' is not also set in 'tmp'.  Clear the found 'source'
- * bit in 'tmp', and return that <source, dest> pair for migration.
- * The pair of nodemasks 'to' and 'from' define the map.
- *
- * If no pair of bits is found that way, fallback to picking some
- * pair of 'source' and 'dest' bits that are not the same.  If the
- * 'source' and 'dest' bits are the same, this represents a node
- * that will be migrating to itself, so no pages need move.
- *
- * If no bits are left in 'tmp', or if all remaining bits left
- * in 'tmp' correspond to the same bit in 'to', return false
- * (nothing left to migrate).
- *
- * This lets us pick a pair of nodes to migrate between, such that
- * if possible the dest node is not already occupied by some other
- * source node, minimizing the risk of overloading the memory on a
- * node that would happen if we migrated incoming memory to a node
- * before migrating outgoing memory source that same node.
- *
- * A single scan of tmp is sufficient.  As we go, we remember the
- * most recent <s, d> pair that moved (s != d).  If we find a pair
- * that not only moved, but what's better, moved to an empty slot
- * (d is not set in tmp), then we break out then, with that pair.
- * Otherwise when we finish scannng from_tmp, we at least have the
- * most recent <s, d> pair that moved.  If we get all the way through
- * the scan of tmp without finding any node that moved, much less
- * moved to an empty node, then there is nothing left worth migrating.
- */
+	/*
+	 * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
+	 * bit in 'to' is not also set in 'tmp'.  Clear the found 'source'
+	 * bit in 'tmp', and return that <source, dest> pair for migration.
+	 * The pair of nodemasks 'to' and 'from' define the map.
+	 *
+	 * If no pair of bits is found that way, fallback to picking some
+	 * pair of 'source' and 'dest' bits that are not the same.  If the
+	 * 'source' and 'dest' bits are the same, this represents a node
+	 * that will be migrating to itself, so no pages need move.
+	 *
+	 * If no bits are left in 'tmp', or if all remaining bits left
+	 * in 'tmp' correspond to the same bit in 'to', return false
+	 * (nothing left to migrate).
+	 *
+	 * This lets us pick a pair of nodes to migrate between, such that
+	 * if possible the dest node is not already occupied by some other
+	 * source node, minimizing the risk of overloading the memory on a
+	 * node that would happen if we migrated incoming memory to a node
+	 * before migrating outgoing memory source that same node.
+	 *
+	 * A single scan of tmp is sufficient.  As we go, we remember the
+	 * most recent <s, d> pair that moved (s != d).  If we find a pair
+	 * that not only moved, but what's better, moved to an empty slot
+	 * (d is not set in tmp), then we break out then, with that pair.
+	 * Otherwise when we finish scannng from_tmp, we at least have the
+	 * most recent <s, d> pair that moved.  If we get all the way through
+	 * the scan of tmp without finding any node that moved, much less
+	 * moved to an empty node, then there is nothing left worth migrating.
+	 */
 
 	tmp = *from_nodes;
 	while (!nodes_empty(tmp)) {
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
