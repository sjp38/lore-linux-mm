Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 77F0B6B0037
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 09:02:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 22:56:37 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1D36B3578052
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:02:15 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3DD1dEi4784500
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:39 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3DD1hSx019691
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:44 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART3 v4 3/6] staging: ramster: Add incremental accessory counters
Date: Sat, 13 Apr 2013 21:01:29 +0800
Message-Id: <1365858092-21920-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Add incremental accessory counters that are going to be used for 
debug fs entries.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

---
 drivers/staging/zcache/ramster/debug.h   |   67 ++++++++++++++++++++++++++++++
 drivers/staging/zcache/ramster/ramster.c |   32 +++++++-------
 2 files changed, 83 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/zcache/ramster/debug.h b/drivers/staging/zcache/ramster/debug.h
index 3f608b7..4428c79 100644
--- a/drivers/staging/zcache/ramster/debug.h
+++ b/drivers/staging/zcache/ramster/debug.h
@@ -62,6 +62,59 @@ extern ssize_t ramster_remote_page_flushes_failed;
 
 int ramster_debugfs_init(void);
 
+static inline void inc_ramster_eph_pages_remoted(void)
+{
+	ramster_eph_pages_remoted++;
+};
+static inline void inc_ramster_pers_pages_remoted(void)
+{
+	ramster_pers_pages_remoted++;
+};
+static inline void inc_ramster_eph_pages_remote_failed(void)
+{
+	ramster_eph_pages_remote_failed++;
+};
+static inline void inc_ramster_pers_pages_remote_failed(void)
+{
+	ramster_pers_pages_remote_failed++;
+};
+static inline void inc_ramster_remote_eph_pages_succ_get(void)
+{
+	ramster_remote_eph_pages_succ_get++;
+};
+static inline void inc_ramster_remote_pers_pages_succ_get(void)
+{
+	ramster_remote_pers_pages_succ_get++;
+};
+static inline void inc_ramster_remote_eph_pages_unsucc_get(void)
+{
+	ramster_remote_eph_pages_unsucc_get++;
+};
+static inline void inc_ramster_remote_pers_pages_unsucc_get(void)
+{
+	ramster_remote_pers_pages_unsucc_get++;
+};
+static inline void inc_ramster_pers_pages_remote_nomem(void)
+{
+	ramster_pers_pages_remote_nomem++;
+};
+static inline void inc_ramster_remote_objects_flushed(void)
+{
+	ramster_remote_objects_flushed++;
+};
+static inline void inc_ramster_remote_object_flushes_failed(void)
+{
+	ramster_remote_object_flushes_failed++;
+};
+static inline void inc_ramster_remote_pages_flushed(void)
+{
+	ramster_remote_pages_flushed++;
+};
+static inline void inc_ramster_remote_page_flushes_failed(void)
+{
+	ramster_remote_page_flushes_failed++;
+};
+
 #else
 
 static inline void inc_ramster_flnodes(void) { };
@@ -71,6 +124,20 @@ static inline void dec_ramster_foreign_eph_pages(void) { };
 static inline void inc_ramster_foreign_pers_pages(void) { };
 static inline void dec_ramster_foreign_pers_pages(void) { };
 
+static inline void inc_ramster_eph_pages_remoted(void) { };
+static inline void inc_ramster_pers_pages_remoted(void) { };
+static inline void inc_ramster_eph_pages_remote_failed(void) { };
+static inline void inc_ramster_pers_pages_remote_failed(void) { };
+static inline void inc_ramster_remote_eph_pages_succ_get(void) { };
+static inline void inc_ramster_remote_pers_pages_succ_get(void) { };
+static inline void inc_ramster_remote_eph_pages_unsucc_get(void) { };
+static inline void inc_ramster_remote_pers_pages_unsucc_get(void) { };
+static inline void inc_ramster_pers_pages_remote_nomem(void) { };
+static inline void inc_ramster_remote_objects_flushed(void) { };
+static inline void inc_ramster_remote_object_flushes_failed(void) { };
+static inline void inc_ramster_remote_pages_flushed(void) { };
+static inline void inc_ramster_remote_page_flushes_failed(void) { };
+
 static inline int ramster_debugfs_init(void)
 {
 	return 0;
diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
index 1d29f5b..8781627 100644
--- a/drivers/staging/zcache/ramster/ramster.c
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -156,9 +156,9 @@ int ramster_localify(int pool_id, struct tmem_oid *oidp, uint32_t index,
 		pr_err("UNTESTED pampd==NULL in ramster_localify\n");
 #endif
 		if (eph)
-			ramster_remote_eph_pages_unsucc_get++;
+			inc_ramster_remote_eph_pages_unsucc_get();
 		else
-			ramster_remote_pers_pages_unsucc_get++;
+			inc_ramster_remote_pers_pages_unsucc_get();
 		obj = NULL;
 		goto finish;
 	} else if (unlikely(!pampd_is_remote(pampd))) {
@@ -167,9 +167,9 @@ int ramster_localify(int pool_id, struct tmem_oid *oidp, uint32_t index,
 		pr_err("UNTESTED dup while waiting in ramster_localify\n");
 #endif
 		if (eph)
-			ramster_remote_eph_pages_unsucc_get++;
+			inc_ramster_remote_eph_pages_unsucc_get();
 		else
-			ramster_remote_pers_pages_unsucc_get++;
+			inc_ramster_remote_pers_pages_unsucc_get();
 		obj = NULL;
 		pampd = NULL;
 		ret = -EEXIST;
@@ -178,7 +178,7 @@ int ramster_localify(int pool_id, struct tmem_oid *oidp, uint32_t index,
 		/* no remote data, delete the local is_remote pampd */
 		pampd = NULL;
 		if (eph)
-			ramster_remote_eph_pages_unsucc_get++;
+			inc_ramster_remote_eph_pages_unsucc_get();
 		else
 			BUG();
 		delete = true;
@@ -209,9 +209,9 @@ int ramster_localify(int pool_id, struct tmem_oid *oidp, uint32_t index,
 	BUG_ON(extra == NULL);
 	zcache_decompress_to_page(data, size, (struct page *)extra);
 	if (eph)
-		ramster_remote_eph_pages_succ_get++;
+		inc_ramster_remote_eph_pages_succ_get();
 	else
-		ramster_remote_pers_pages_succ_get++;
+		inc_ramster_remote_pers_pages_succ_get();
 	ret = 0;
 finish:
 	tmem_localify_finish(obj, index, pampd, saved_hb, delete);
@@ -296,7 +296,7 @@ void *ramster_pampd_repatriate_preload(void *pampd, struct tmem_pool *pool,
 		c = atomic_dec_return(&ramster_remote_pers_pages);
 		WARN_ON_ONCE(c < 0);
 	} else {
-		ramster_pers_pages_remote_nomem++;
+		inc_ramster_pers_pages_remote_nomem();
 	}
 	local_irq_restore(flags);
 out:
@@ -435,9 +435,9 @@ static void ramster_remote_flush_page(struct flushlist_node *flnode)
 	remotenode = flnode->xh.client_id;
 	ret = r2net_remote_flush(xh, remotenode);
 	if (ret >= 0)
-		ramster_remote_pages_flushed++;
+		inc_ramster_remote_pages_flushed();
 	else
-		ramster_remote_page_flushes_failed++;
+		inc_ramster_remote_page_flushes_failed();
 	preempt_enable_no_resched();
 	ramster_flnode_free(flnode, NULL);
 }
@@ -452,9 +452,9 @@ static void ramster_remote_flush_object(struct flushlist_node *flnode)
 	remotenode = flnode->xh.client_id;
 	ret = r2net_remote_flush_object(xh, remotenode);
 	if (ret >= 0)
-		ramster_remote_objects_flushed++;
+		inc_ramster_remote_objects_flushed();
 	else
-		ramster_remote_object_flushes_failed++;
+		inc_ramster_remote_object_flushes_failed();
 	preempt_enable_no_resched();
 	ramster_flnode_free(flnode, NULL);
 }
@@ -505,18 +505,18 @@ int ramster_remotify_pageframe(bool eph)
 		 * But count them so we know if it becomes a problem.
 		 */
 			if (eph)
-				ramster_eph_pages_remote_failed++;
+				inc_ramster_eph_pages_remote_failed();
 			else
-				ramster_pers_pages_remote_failed++;
+				inc_ramster_pers_pages_remote_failed();
 			break;
 		} else {
 			if (!eph)
 				atomic_inc(&ramster_remote_pers_pages);
 		}
 		if (eph)
-			ramster_eph_pages_remoted++;
+			inc_ramster_eph_pages_remoted();
 		else
-			ramster_pers_pages_remoted++;
+			inc_ramster_pers_pages_remoted();
 		/*
 		 * data was successfully remoted so change the local version to
 		 * point to the remote node where it landed
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
