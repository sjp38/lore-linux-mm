Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F38F9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 21:01:50 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] mm/mempolicy.c: quiet sparse noise
Date: Thu, 22 Sep 2011 18:01:40 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <201109221801.41253.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wilsons@start.ca, aarcange@redhat.com, mel@csn.ul.ie

Quiet the spares noise:

warning: symbol 'default_policy' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Stephen Wilson <wilsons@start.ca>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>

---

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 905f202..b7667a7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -111,7 +111,7 @@ enum zone_type policy_zone = 0;
 /*
  * run-time system-wide default policy => local allocation
  */
-struct mempolicy default_policy = {
+static struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
 	.mode = MPOL_PREFERRED,
 	.flags = MPOL_F_LOCAL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
