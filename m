Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CE9696B008C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:54:59 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/7] move include of workqueue.h to top of slab.h file
Date: Thu, 15 Nov 2012 06:54:48 +0400
Message-Id: <1352948093-2315-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-1-git-send-email-glommer@parallels.com>
References: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

Suggested by akpm. I originally decided to put it closer to the use of
the work struct, but let's move it to top.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 81ee767..18f8c98 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -11,6 +11,8 @@
 
 #include <linux/gfp.h>
 #include <linux/types.h>
+#include <linux/workqueue.h>
+
 
 /*
  * Flags to pass to kmem_cache_create().
@@ -180,8 +182,6 @@ unsigned int kmem_cache_size(struct kmem_cache *);
 #ifndef ARCH_SLAB_MINALIGN
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
-
-#include <linux/workqueue.h>
 /*
  * This is the main placeholder for memcg-related information in kmem caches.
  * struct kmem_cache will hold a pointer to it, so the memory cost while
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
