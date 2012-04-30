Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D56986B0081
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 06:03:24 -0400 (EDT)
Received: by dadq36 with SMTP id q36so3887109dad.8
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 03:03:24 -0700 (PDT)
Date: Mon, 30 Apr 2012 03:02:02 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 3/3] slab: Get rid of mem_cgroup_put_kmem_cache()
Message-ID: <20120430100202.GC28569@lizard>
References: <20120430095918.GA13824@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120430095918.GA13824@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, John Stultz <john.stultz@linaro.org>, linaro-kernel@lists.linaro.org, patches@linaro.org

The function is no longer used, so can be safely removed.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/slab_def.h |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 2d371ae..72ea626 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -232,12 +232,6 @@ kmem_cache_get_ref(struct kmem_cache *cachep)
 }
 
 static inline void
-mem_cgroup_put_kmem_cache(struct kmem_cache *cachep)
-{
-	rcu_read_unlock();
-}
-
-static inline void
 mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
 {
 	/*
@@ -266,11 +260,6 @@ kmem_cache_drop_ref(struct kmem_cache *cachep)
 }
 
 static inline void
-mem_cgroup_put_kmem_cache(struct kmem_cache *cachep)
-{
-}
-
-static inline void
 mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
 {
 }
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
