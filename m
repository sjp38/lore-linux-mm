Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C0D286B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 02:55:13 -0500 (EST)
Subject: [patch] slub: fix a code merge error
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Nov 2011 16:04:20 +0800
Message-ID: <1320912260.22361.247.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: penberg@kernel.org, cl@linux-foundation.org

Looks there is a merge error in the slub tree. DEACTIVATE_TO_TAIL != 1.
And this will cause performance regression.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..60e16c4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1904,7 +1904,8 @@ static void unfreeze_partials(struct kmem_cache *s)
 				if (l == M_PARTIAL)
 					remove_partial(n, page);
 				else
-					add_partial(n, page, 1);
+					add_partial(n, page,
+						DEACTIVATE_TO_TAIL);
 
 				l = m;
 			}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
