Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 564696B00C0
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:52 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 09/11] zcache: Allow to compile if ZCACHE_DEBUG and !DEBUG_FS
Date: Wed, 14 Nov 2012 14:12:17 -0500
Message-Id: <1352920339-10183-10-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

is defined.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/debug.h |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/ramster/debug.h b/drivers/staging/ramster/debug.h
index 35af06d..b412b90 100644
--- a/drivers/staging/ramster/debug.h
+++ b/drivers/staging/ramster/debug.h
@@ -174,7 +174,6 @@ static inline void inc_zcache_evicted_eph_pageframes(void) { zcache_evicted_eph_
 static inline void inc_zcache_eph_nonactive_puts_ignored(void) { zcache_eph_nonactive_puts_ignored ++; };
 static inline void inc_zcache_pers_nonactive_puts_ignored(void) { zcache_pers_nonactive_puts_ignored ++; };
 
-int zcache_debugfs_init(void);
 #else
 static inline void inc_zcache_obj_count(void) { };
 static inline void dec_zcache_obj_count(void) { };
@@ -198,10 +197,6 @@ static inline unsigned long curr_pageframes_count(void)
 {
 	return 0;
 };
-static inline int zcache_debugfs_init(void)
-{
-	return 0;
-};
 static inline void inc_zcache_flush_total(void) { };
 static inline void inc_zcache_flush_found(void) { };
 static inline void inc_zcache_flobj_total(void) { };
@@ -223,3 +218,12 @@ static inline void inc_zcache_evicted_eph_pageframes(void) { };
 static inline void inc_zcache_eph_nonactive_puts_ignored(void) { };
 static inline void inc_zcache_pers_nonactive_puts_ignored(void) { };
 #endif
+
+#ifdef CONFIG_DEBUG_FS
+int zcache_debugfs_init(void);
+#else
+static inline int zcache_debugfs_init(void)
+{
+	return 0;
+};
+#endif
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
