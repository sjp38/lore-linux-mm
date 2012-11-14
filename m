Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 4A2B16B00BF
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:46 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 05/11] zcache: Make the debug code use pr_debug
Date: Wed, 14 Nov 2012 14:12:13 -0500
Message-Id: <1352920339-10183-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

as if you are debugging this driver you would be using 'debug'
on the command line anyhow - and this would dump the debug
data on the proper loglevel.

While at it also remove the unconditional #define ZCACHE_DEBUG.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |   69 ++++++++++++++++-----------------
 1 files changed, 33 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 6988f5c..a43c3b0 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -349,56 +349,53 @@ static int zcache_debugfs_init(void)
 #undef	zdfs64
 #endif
 
-#define ZCACHE_DEBUG
-#ifdef ZCACHE_DEBUG
 /* developers can call this in case of ooms, e.g. to find memory leaks */
 void zcache_dump(void)
 {
-	pr_info("zcache: obj_count=%u\n", zcache_obj_count);
-	pr_info("zcache: obj_count_max=%u\n", zcache_obj_count_max);
-	pr_info("zcache: objnode_count=%u\n", zcache_objnode_count);
-	pr_info("zcache: objnode_count_max=%u\n", zcache_objnode_count_max);
-	pr_info("zcache: flush_total=%u\n", zcache_flush_total);
-	pr_info("zcache: flush_found=%u\n", zcache_flush_found);
-	pr_info("zcache: flobj_total=%u\n", zcache_flobj_total);
-	pr_info("zcache: flobj_found=%u\n", zcache_flobj_found);
-	pr_info("zcache: failed_eph_puts=%u\n", zcache_failed_eph_puts);
-	pr_info("zcache: failed_pers_puts=%u\n", zcache_failed_pers_puts);
-	pr_info("zcache: failed_get_free_pages=%u\n",
+	pr_debug("zcache: obj_count=%u\n", zcache_obj_count);
+	pr_debug("zcache: obj_count_max=%u\n", zcache_obj_count_max);
+	pr_debug("zcache: objnode_count=%u\n", zcache_objnode_count);
+	pr_debug("zcache: objnode_count_max=%u\n", zcache_objnode_count_max);
+	pr_debug("zcache: flush_total=%u\n", zcache_flush_total);
+	pr_debug("zcache: flush_found=%u\n", zcache_flush_found);
+	pr_debug("zcache: flobj_total=%u\n", zcache_flobj_total);
+	pr_debug("zcache: flobj_found=%u\n", zcache_flobj_found);
+	pr_debug("zcache: failed_eph_puts=%u\n", zcache_failed_eph_puts);
+	pr_debug("zcache: failed_pers_puts=%u\n", zcache_failed_pers_puts);
+	pr_debug("zcache: failed_get_free_pages=%u\n",
 				zcache_failed_getfreepages);
-	pr_info("zcache: failed_alloc=%u\n", zcache_failed_alloc);
-	pr_info("zcache: put_to_flush=%u\n", zcache_put_to_flush);
-	pr_info("zcache: compress_poor=%u\n", zcache_compress_poor);
-	pr_info("zcache: mean_compress_poor=%u\n",
+	pr_debug("zcache: failed_alloc=%u\n", zcache_failed_alloc);
+	pr_debug("zcache: put_to_flush=%u\n", zcache_put_to_flush);
+	pr_debug("zcache: compress_poor=%u\n", zcache_compress_poor);
+	pr_debug("zcache: mean_compress_poor=%u\n",
 				zcache_mean_compress_poor);
-	pr_info("zcache: eph_ate_tail=%u\n", zcache_eph_ate_tail);
-	pr_info("zcache: eph_ate_tail_failed=%u\n",
+	pr_debug("zcache: eph_ate_tail=%u\n", zcache_eph_ate_tail);
+	pr_debug("zcache: eph_ate_tail_failed=%u\n",
 				zcache_eph_ate_tail_failed);
-	pr_info("zcache: pers_ate_eph=%u\n", zcache_pers_ate_eph);
-	pr_info("zcache: pers_ate_eph_failed=%u\n",
+	pr_debug("zcache: pers_ate_eph=%u\n", zcache_pers_ate_eph);
+	pr_debug("zcache: pers_ate_eph_failed=%u\n",
 				zcache_pers_ate_eph_failed);
-	pr_info("zcache: evicted_eph_zpages=%u\n", zcache_evicted_eph_zpages);
-	pr_info("zcache: evicted_eph_pageframes=%u\n",
+	pr_debug("zcache: evicted_eph_zpages=%u\n", zcache_evicted_eph_zpages);
+	pr_debug("zcache: evicted_eph_pageframes=%u\n",
 				zcache_evicted_eph_pageframes);
-	pr_info("zcache: eph_pageframes=%u\n", zcache_eph_pageframes);
-	pr_info("zcache: eph_pageframes_max=%u\n", zcache_eph_pageframes_max);
-	pr_info("zcache: pers_pageframes=%u\n", zcache_pers_pageframes);
-	pr_info("zcache: pers_pageframes_max=%u\n",
+	pr_debug("zcache: eph_pageframes=%u\n", zcache_eph_pageframes);
+	pr_debug("zcache: eph_pageframes_max=%u\n", zcache_eph_pageframes_max);
+	pr_debug("zcache: pers_pageframes=%u\n", zcache_pers_pageframes);
+	pr_debug("zcache: pers_pageframes_max=%u\n",
 				zcache_pers_pageframes_max);
-	pr_info("zcache: eph_zpages=%u\n", zcache_eph_zpages);
-	pr_info("zcache: eph_zpages_max=%u\n", zcache_eph_zpages_max);
-	pr_info("zcache: pers_zpages=%u\n", zcache_pers_zpages);
-	pr_info("zcache: pers_zpages_max=%u\n", zcache_pers_zpages_max);
-	pr_info("zcache: eph_zbytes=%llu\n",
+	pr_debug("zcache: eph_zpages=%u\n", zcache_eph_zpages);
+	pr_debug("zcache: eph_zpages_max=%u\n", zcache_eph_zpages_max);
+	pr_debug("zcache: pers_zpages=%u\n", zcache_pers_zpages);
+	pr_debug("zcache: pers_zpages_max=%u\n", zcache_pers_zpages_max);
+	pr_debug("zcache: eph_zbytes=%llu\n",
 				(unsigned long long)zcache_eph_zbytes);
-	pr_info("zcache: eph_zbytes_max=%llu\n",
+	pr_debug("zcache: eph_zbytes_max=%llu\n",
 				(unsigned long long)zcache_eph_zbytes_max);
-	pr_info("zcache: pers_zbytes=%llu\n",
+	pr_debug("zcache: pers_zbytes=%llu\n",
 				(unsigned long long)zcache_pers_zbytes);
-	pr_info("zcache: pers_zbytes_max=%llu\n",
+	pr_debug("zcache: pers_zbytes_max=%llu\n",
 			(unsigned long long)zcache_pers_zbytes_max);
 }
-#endif
 
 /*
  * zcache core code starts here
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
