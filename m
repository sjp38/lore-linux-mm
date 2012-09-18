Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DF4836B00C0
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:16:42 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 03/16] slab: Ignore the cflgs bit in cache creation
Date: Tue, 18 Sep 2012 18:11:57 +0400
Message-Id: <1347977530-29755-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1347977530-29755-1-git-send-email-glommer@parallels.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

No cache should ever pass that as a creation flag, since this bit is
used to mark an internal decision of the slab about object placement. We
can just ignore this bit if it happens to be passed (such as when
duplicating a cache in the kmem memcg patches)

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slab.c b/mm/slab.c
index a7ed60f..ccf496c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2373,6 +2373,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	int err;
 	size_t size = cachep->size;
 
+	flags &= ~CFLGS_OFF_SLAB;
 #if DEBUG
 #if FORCED_DEBUG
 	/*
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
