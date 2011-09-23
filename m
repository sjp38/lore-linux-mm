Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B9C4C9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 20:54:46 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] mm/thrash.c: quiet sparse noise
Date: Thu, 22 Sep 2011 17:54:33 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <201109221754.34162.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com

Quiet the following sparse noise:

warning: symbol 'swap_token_memcg' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---

diff --git a/mm/thrash.c b/mm/thrash.c
index e53f7d0..57ad495 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -29,7 +29,7 @@
 
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
-struct mem_cgroup *swap_token_memcg;
+static struct mem_cgroup *swap_token_memcg;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 static struct mem_cgroup *swap_token_memcg_from_mm(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
