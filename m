Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3403B8D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:19:21 -0400 (EDT)
Message-ID: <4DA3FDB2.9090100@cn.fujitsu.com>
Date: Tue, 12 Apr 2011 15:22:26 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] slub: Fix a typo in config name
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux.com, penberg@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

There's no config named SLAB_DEBUG, and it should be a typo
of SLUB_DEBUG.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

not slub expert, don't know how this bug affects slub debugging.

---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 94d2a33..df77f78 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3203,7 +3203,7 @@ static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
 			list_for_each_entry(p, &n->partial, lru)
 				p->slab = s;
 
-#ifdef CONFIG_SLAB_DEBUG
+#ifdef CONFIG_SLUB_DEBUG
 			list_for_each_entry(p, &n->full, lru)
 				p->slab = s;
 #endif
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
