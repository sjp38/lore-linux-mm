Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 91ED08D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:10:10 -0500 (EST)
Date: Thu, 3 Feb 2011 15:10:00 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: remove unused page flag bitfield defines
Message-ID: <20110203141000.GE2286@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

These definitions have been unused since '4b3bde4 memcg: remove the
overhead associated with the root cgroup'.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

(sorry, resend with lists in CC)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e1ab9c3..031ff07 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -327,13 +327,6 @@ enum charge_type {
 	NR_CHARGE_TYPE,
 };
 
-/* only for here (for easy reading.) */
-#define PCGF_CACHE	(1UL << PCG_CACHE)
-#define PCGF_USED	(1UL << PCG_USED)
-#define PCGF_LOCK	(1UL << PCG_LOCK)
-/* Not used, but added here for completeness */
-#define PCGF_ACCT	(1UL << PCG_ACCT)
-
 /* for encoding cft->private value on file */
 #define _MEM			(0)
 #define _MEMSWAP		(1)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
