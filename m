Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3CE566B00B8
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:51 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 08/11] zcache: Move the last of the debugfs counters out
Date: Wed, 14 Nov 2012 14:12:16 -0500
Message-Id: <1352920339-10183-9-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

We now have in zcache-main only the counters that are
are not debugfs related.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/debug.h       |   80 +++++++++++++++++++++++++--------
 drivers/staging/ramster/zcache-main.c |   71 +++++++++++------------------
 2 files changed, 87 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/ramster/debug.h b/drivers/staging/ramster/debug.h
index 496735b..35af06d 100644
--- a/drivers/staging/ramster/debug.h
+++ b/drivers/staging/ramster/debug.h
@@ -128,29 +128,51 @@ static inline unsigned long curr_pageframes_count(void)
 		atomic_read(&zcache_pers_pageframes_atomic);
 };
 /* but for the rest of these, counting races are ok */
-extern ssize_t zcache_flush_total;
-extern ssize_t zcache_flush_found;
-extern ssize_t zcache_flobj_total;
-extern ssize_t zcache_flobj_found;
-extern ssize_t zcache_failed_eph_puts;
-extern ssize_t zcache_failed_pers_puts;
-extern ssize_t zcache_failed_getfreepages;
-extern ssize_t zcache_failed_alloc;
-extern ssize_t zcache_put_to_flush;
-extern ssize_t zcache_compress_poor;
-extern ssize_t zcache_mean_compress_poor;
-extern ssize_t zcache_eph_ate_tail;
-extern ssize_t zcache_eph_ate_tail_failed;
-extern ssize_t zcache_pers_ate_eph;
-extern ssize_t zcache_pers_ate_eph_failed;
-extern ssize_t zcache_evicted_eph_zpages;
-extern ssize_t zcache_evicted_eph_pageframes;
+static ssize_t zcache_flush_total;
+static ssize_t zcache_flush_found;
+static ssize_t zcache_flobj_total;
+static ssize_t zcache_flobj_found;
+static ssize_t zcache_failed_eph_puts;
+static ssize_t zcache_failed_pers_puts;
+static ssize_t zcache_failed_getfreepages;
+static ssize_t zcache_failed_alloc;
+static ssize_t zcache_put_to_flush;
+static ssize_t zcache_compress_poor;
+static ssize_t zcache_mean_compress_poor;
+static ssize_t zcache_eph_ate_tail;
+static ssize_t zcache_eph_ate_tail_failed;
+static ssize_t zcache_pers_ate_eph;
+static ssize_t zcache_pers_ate_eph_failed;
+static ssize_t zcache_evicted_eph_zpages;
+static ssize_t zcache_evicted_eph_pageframes;
+
 extern ssize_t zcache_last_active_file_pageframes;
 extern ssize_t zcache_last_inactive_file_pageframes;
 extern ssize_t zcache_last_active_anon_pageframes;
 extern ssize_t zcache_last_inactive_anon_pageframes;
-extern ssize_t zcache_eph_nonactive_puts_ignored;
-extern ssize_t zcache_pers_nonactive_puts_ignored;
+static ssize_t zcache_eph_nonactive_puts_ignored;
+static ssize_t zcache_pers_nonactive_puts_ignored;
+
+static inline void inc_zcache_flush_total(void) { zcache_flush_total ++; };
+static inline void inc_zcache_flush_found(void) { zcache_flush_found ++; };
+static inline void inc_zcache_flobj_total(void) { zcache_flobj_total ++; };
+static inline void inc_zcache_flobj_found(void) { zcache_flobj_found ++; };
+static inline void inc_zcache_failed_eph_puts(void) { zcache_failed_eph_puts ++; };
+static inline void inc_zcache_failed_pers_puts(void) { zcache_failed_pers_puts ++; };
+static inline void inc_zcache_failed_getfreepages(void) { zcache_failed_getfreepages ++; };
+static inline void inc_zcache_failed_alloc(void) { zcache_failed_alloc ++; };
+static inline void inc_zcache_put_to_flush(void) { zcache_put_to_flush ++; };
+static inline void inc_zcache_compress_poor(void) { zcache_compress_poor ++; };
+static inline void inc_zcache_mean_compress_poor(void) { zcache_mean_compress_poor ++; };
+static inline void inc_zcache_eph_ate_tail(void) { zcache_eph_ate_tail ++; };
+static inline void inc_zcache_eph_ate_tail_failed(void) { zcache_eph_ate_tail_failed ++; };
+static inline void inc_zcache_pers_ate_eph(void) { zcache_pers_ate_eph ++; };
+static inline void inc_zcache_pers_ate_eph_failed(void) { zcache_pers_ate_eph_failed ++; };
+static inline void inc_zcache_evicted_eph_zpages(void) { zcache_evicted_eph_zpages ++; };
+static inline void inc_zcache_evicted_eph_pageframes(void) { zcache_evicted_eph_pageframes ++; };
+
+static inline void inc_zcache_eph_nonactive_puts_ignored(void) { zcache_eph_nonactive_puts_ignored ++; };
+static inline void inc_zcache_pers_nonactive_puts_ignored(void) { zcache_pers_nonactive_puts_ignored ++; };
 
 int zcache_debugfs_init(void);
 #else
@@ -180,4 +202,24 @@ static inline int zcache_debugfs_init(void)
 {
 	return 0;
 };
+static inline void inc_zcache_flush_total(void) { };
+static inline void inc_zcache_flush_found(void) { };
+static inline void inc_zcache_flobj_total(void) { };
+static inline void inc_zcache_flobj_found(void) { };
+static inline void inc_zcache_failed_eph_puts(void) { };
+static inline void inc_zcache_failed_pers_puts(void) { };
+static inline void inc_zcache_failed_getfreepages(void) { };
+static inline void inc_zcache_failed_alloc(void) { };
+static inline void inc_zcache_put_to_flush(void) { };
+static inline void inc_zcache_compress_poor(void) { };
+static inline void inc_zcache_mean_compress_poor(void) { };
+static inline void inc_zcache_eph_ate_tail(void) { };
+static inline void inc_zcache_eph_ate_tail_failed(void) { };
+static inline void inc_zcache_pers_ate_eph(void) { };
+static inline void inc_zcache_pers_ate_eph_failed(void) { };
+static inline void inc_zcache_evicted_eph_zpages(void) { };
+static inline void inc_zcache_evicted_eph_pageframes(void) { };
+
+static inline void inc_zcache_eph_nonactive_puts_ignored(void) { };
+static inline void inc_zcache_pers_nonactive_puts_ignored(void) { };
 #endif
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 52c29de..457e41c 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -141,29 +141,10 @@ ssize_t zcache_eph_pageframes;
 ssize_t zcache_pers_pageframes;
 
 /* Used by this code. */
-static ssize_t zcache_flush_total;
-static ssize_t zcache_flush_found;
-static ssize_t zcache_flobj_total;
-static ssize_t zcache_flobj_found;
-static ssize_t zcache_failed_eph_puts;
-static ssize_t zcache_failed_pers_puts;
-static ssize_t zcache_failed_getfreepages;
-static ssize_t zcache_failed_alloc;
-static ssize_t zcache_put_to_flush;
-static ssize_t zcache_compress_poor;
-static ssize_t zcache_mean_compress_poor;
-static ssize_t zcache_eph_ate_tail;
-static ssize_t zcache_eph_ate_tail_failed;
-static ssize_t zcache_pers_ate_eph;
-static ssize_t zcache_pers_ate_eph_failed;
-static ssize_t zcache_evicted_eph_zpages;
-static ssize_t zcache_evicted_eph_pageframes;
-static ssize_t zcache_last_active_file_pageframes;
-static ssize_t zcache_last_inactive_file_pageframes;
-static ssize_t zcache_last_active_anon_pageframes;
-static ssize_t zcache_last_inactive_anon_pageframes;
-static ssize_t zcache_eph_nonactive_puts_ignored;
-static ssize_t zcache_pers_nonactive_puts_ignored;
+ssize_t zcache_last_active_file_pageframes;
+ssize_t zcache_last_inactive_file_pageframes;
+ssize_t zcache_last_active_anon_pageframes;
+ssize_t zcache_last_inactive_anon_pageframes;
 /*
  * zcache core code starts here
  */
@@ -356,7 +337,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 	if (!raw) {
 		zcache_compress(page, &cdata, &clen);
 		if (clen > zbud_max_buddy_size()) {
-			zcache_compress_poor++;
+			inc_zcache_compress_poor();
 			goto out;
 		}
 	} else {
@@ -373,14 +354,14 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 	if (newpage != NULL)
 		goto create_in_new_page;
 
-	zcache_failed_getfreepages++;
+	inc_zcache_failed_getfreepages();
 	/* can't allocate a page, evict an ephemeral page via LRU */
 	newpage = zcache_evict_eph_pageframe();
 	if (newpage == NULL) {
-		zcache_eph_ate_tail_failed++;
+		inc_zcache_eph_ate_tail_failed();
 		goto out;
 	}
-	zcache_eph_ate_tail++;
+	inc_zcache_eph_ate_tail();
 
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, true, cdata, clen, newpage);
@@ -415,7 +396,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		zcache_compress(page, &cdata, &clen);
 	/* reject if compression is too poor */
 	if (clen > zbud_max_zsize) {
-		zcache_compress_poor++;
+		inc_zcache_compress_poor();
 		goto out;
 	}
 	/* reject if mean compression is too poor */
@@ -426,7 +407,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		zbud_mean_zsize = div_u64(total_zsize,
 					curr_pers_zpages);
 		if (zbud_mean_zsize > zbud_max_mean_zsize) {
-			zcache_mean_compress_poor++;
+			inc_zcache_mean_compress_poor();
 			goto out;
 		}
 	}
@@ -447,14 +428,14 @@ create_pampd:
 	 * (global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE) +
 	 * global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE)))
 	 */
-	zcache_failed_getfreepages++;
+	inc_zcache_failed_getfreepages();
 	/* can't allocate a page, evict an ephemeral page via LRU */
 	newpage = zcache_evict_eph_pageframe();
 	if (newpage == NULL) {
-		zcache_pers_ate_eph_failed++;
+		inc_zcache_pers_ate_eph_failed();
 		goto out;
 	}
-	zcache_pers_ate_eph++;
+	inc_zcache_pers_ate_eph();
 
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, false, cdata, clen, newpage);
@@ -494,7 +475,7 @@ void *zcache_pampd_create(char *data, unsigned int size, bool raw,
 			objnode = kmem_cache_alloc(zcache_objnode_cache,
 							ZCACHE_GFP_MASK);
 			if (unlikely(objnode == NULL)) {
-				zcache_failed_alloc++;
+				inc_zcache_failed_alloc();
 				goto out;
 			}
 			kp->objnodes[i] = objnode;
@@ -505,7 +486,7 @@ void *zcache_pampd_create(char *data, unsigned int size, bool raw,
 		kp->obj = obj;
 	}
 	if (unlikely(kp->obj == NULL)) {
-		zcache_failed_alloc++;
+		inc_zcache_failed_alloc();
 		goto out;
 	}
 	/*
@@ -783,9 +764,9 @@ static struct page *zcache_evict_eph_pageframe(void)
 		goto out;
 	dec_zcache_eph_zbytes(zsize);
 	dec_zcache_eph_zpages(zpages);
-	zcache_evicted_eph_zpages++;
+	inc_zcache_evicted_eph_zpages();
 	dec_zcache_eph_pageframes();
-	zcache_evicted_eph_pageframes++;
+	inc_zcache_evicted_eph_pageframes();
 out:
 	return page;
 }
@@ -978,9 +959,9 @@ int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 		if (pampd == NULL) {
 			ret = -ENOMEM;
 			if (ephemeral)
-				zcache_failed_eph_puts++;
+				inc_zcache_failed_eph_puts();
 			else
-				zcache_failed_pers_puts++;
+				inc_zcache_failed_pers_puts();
 		} else {
 			if (ramster_enabled)
 				ramster_do_preload_flnode(pool);
@@ -990,7 +971,7 @@ int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 		}
 		zcache_put_pool(pool);
 	} else {
-		zcache_put_to_flush++;
+		inc_zcache_put_to_flush();
 		if (ramster_enabled)
 			ramster_do_preload_flnode(pool);
 		if (atomic_read(&pool->obj_count) > 0)
@@ -1040,7 +1021,7 @@ int zcache_flush_page(int cli_id, int pool_id,
 	unsigned long flags;
 
 	local_irq_save(flags);
-	zcache_flush_total++;
+	inc_zcache_flush_total();
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
 	if (ramster_enabled)
 		ramster_do_preload_flnode(pool);
@@ -1050,7 +1031,7 @@ int zcache_flush_page(int cli_id, int pool_id,
 		zcache_put_pool(pool);
 	}
 	if (ret >= 0)
-		zcache_flush_found++;
+		inc_zcache_flush_found();
 	local_irq_restore(flags);
 	return ret;
 }
@@ -1063,7 +1044,7 @@ int zcache_flush_object(int cli_id, int pool_id,
 	unsigned long flags;
 
 	local_irq_save(flags);
-	zcache_flobj_total++;
+	inc_zcache_flobj_total();
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
 	if (ramster_enabled)
 		ramster_do_preload_flnode(pool);
@@ -1073,7 +1054,7 @@ int zcache_flush_object(int cli_id, int pool_id,
 		zcache_put_pool(pool);
 	}
 	if (ret >= 0)
-		zcache_flobj_found++;
+		inc_zcache_flobj_found();
 	local_irq_restore(flags);
 	return ret;
 }
@@ -1239,7 +1220,7 @@ static void zcache_cleancache_put_page(int pool_id,
 	struct tmem_oid oid = *(struct tmem_oid *)&key;
 
 	if (!disable_cleancache_ignore_nonactive && !PageWasActive(page)) {
-		zcache_eph_nonactive_puts_ignored++;
+		inc_zcache_eph_nonactive_puts_ignored();
 		return;
 	}
 	if (likely(ind == index))
@@ -1368,7 +1349,7 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 
 	BUG_ON(!PageLocked(page));
 	if (!disable_frontswap_ignore_nonactive && !PageWasActive(page)) {
-		zcache_pers_nonactive_puts_ignored++;
+		inc_zcache_pers_nonactive_puts_ignored();
 		ret = -ERANGE;
 		goto out;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
