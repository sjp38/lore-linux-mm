Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 634DD6B0083
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 15:39:40 -0500 (EST)
Received: by yhpp61 with SMTP id p61so256085yhp.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 12:39:39 -0800 (PST)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [PATCH v2 08/13] memcg: Make dentry slab memory accounted in kernel memory accounting.
Date: Fri,  9 Mar 2012 12:39:11 -0800
Message-Id: <1331325556-16447-9-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

Signed-off-by: <suleiman@google.com>
---
 fs/dcache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index bcbdb33..cc6dd92 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3022,8 +3022,8 @@ static void __init dcache_init(void)
 	 * but it is probably not worth it because of the cache nature
 	 * of the dcache. 
 	 */
-	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
+	dentry_cache = KMEM_CACHE(dentry, SLAB_RECLAIM_ACCOUNT | SLAB_PANIC |
+	    SLAB_MEM_SPREAD | SLAB_MEMCG_ACCT);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
