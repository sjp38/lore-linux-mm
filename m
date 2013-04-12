Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id AC4536B009F
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:31:51 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 11:20:28 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3D3A72BB0050
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:31:46 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1Ve6U13042050
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:31:40 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1Vjrq015910
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:31:45 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART2 v2 6/7] staging: zcache/debug: fix coding style
Date: Fri, 12 Apr 2013 09:31:26 +0800
Message-Id: <1365730287-16876-7-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Fix coding style issue: ERROR: space prohibited before that '++' (ctx:WxO)
and line beyond 8 characters.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/debug.h |   95 ++++++++++++++++++++++++++++++++--------
 1 file changed, 76 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/zcache/debug.h b/drivers/staging/zcache/debug.h
index ddad92f..8088d28 100644
--- a/drivers/staging/zcache/debug.h
+++ b/drivers/staging/zcache/debug.h
@@ -174,26 +174,83 @@ extern ssize_t zcache_writtenback_pages;
 extern ssize_t zcache_outstanding_writeback_pages;
 #endif
 
-static inline void inc_zcache_flush_total(void) { zcache_flush_total ++; };
-static inline void inc_zcache_flush_found(void) { zcache_flush_found ++; };
-static inline void inc_zcache_flobj_total(void) { zcache_flobj_total ++; };
-static inline void inc_zcache_flobj_found(void) { zcache_flobj_found ++; };
-static inline void inc_zcache_failed_eph_puts(void) { zcache_failed_eph_puts ++; };
-static inline void inc_zcache_failed_pers_puts(void) { zcache_failed_pers_puts ++; };
-static inline void inc_zcache_failed_getfreepages(void) { zcache_failed_getfreepages ++; };
-static inline void inc_zcache_failed_alloc(void) { zcache_failed_alloc ++; };
-static inline void inc_zcache_put_to_flush(void) { zcache_put_to_flush ++; };
-static inline void inc_zcache_compress_poor(void) { zcache_compress_poor ++; };
-static inline void inc_zcache_mean_compress_poor(void) { zcache_mean_compress_poor ++; };
-static inline void inc_zcache_eph_ate_tail(void) { zcache_eph_ate_tail ++; };
-static inline void inc_zcache_eph_ate_tail_failed(void) { zcache_eph_ate_tail_failed ++; };
-static inline void inc_zcache_pers_ate_eph(void) { zcache_pers_ate_eph ++; };
-static inline void inc_zcache_pers_ate_eph_failed(void) { zcache_pers_ate_eph_failed ++; };
-static inline void inc_zcache_evicted_eph_zpages(unsigned zpages) { zcache_evicted_eph_zpages += zpages; };
-static inline void inc_zcache_evicted_eph_pageframes(void) { zcache_evicted_eph_pageframes ++; };
+static inline void inc_zcache_flush_total(void)
+{
+	zcache_flush_total++;
+};
+static inline void inc_zcache_flush_found(void)
+{
+	zcache_flush_found++;
+};
+static inline void inc_zcache_flobj_total(void)
+{
+	zcache_flobj_total++;
+};
+static inline void inc_zcache_flobj_found(void)
+{
+	zcache_flobj_found++;
+};
+static inline void inc_zcache_failed_eph_puts(void)
+{
+	zcache_failed_eph_puts++;
+};
+static inline void inc_zcache_failed_pers_puts(void)
+{
+	zcache_failed_pers_puts++;
+};
+static inline void inc_zcache_failed_getfreepages(void)
+{
+	zcache_failed_getfreepages++;
+};
+static inline void inc_zcache_failed_alloc(void)
+{
+	zcache_failed_alloc++;
+};
+static inline void inc_zcache_put_to_flush(void)
+{
+	zcache_put_to_flush++;
+};
+static inline void inc_zcache_compress_poor(void)
+{
+	zcache_compress_poor++;
+};
+static inline void inc_zcache_mean_compress_poor(void)
+{
+	zcache_mean_compress_poor++;
+};
+static inline void inc_zcache_eph_ate_tail(void)
+{
+	zcache_eph_ate_tail++;
+};
+static inline void inc_zcache_eph_ate_tail_failed(void)
+{
+	zcache_eph_ate_tail_failed++;
+};
+static inline void inc_zcache_pers_ate_eph(void)
+{
+	zcache_pers_ate_eph++;
+};
+static inline void inc_zcache_pers_ate_eph_failed(void)
+{
+	zcache_pers_ate_eph_failed++;
+};
+static inline void inc_zcache_evicted_eph_zpages(unsigned zpages)
+{
+	zcache_evicted_eph_zpages += zpages;
+};
+static inline void inc_zcache_evicted_eph_pageframes(void)
+{
+	zcache_evicted_eph_pageframes++;
+};
 
-static inline void inc_zcache_eph_nonactive_puts_ignored(void) { zcache_eph_nonactive_puts_ignored ++; };
-static inline void inc_zcache_pers_nonactive_puts_ignored(void) { zcache_pers_nonactive_puts_ignored ++; };
+static inline void inc_zcache_eph_nonactive_puts_ignored(void)
+{
+	zcache_eph_nonactive_puts_ignored++;
+};
+static inline void inc_zcache_pers_nonactive_puts_ignored(void)
+{
+	zcache_pers_nonactive_puts_ignored++;
+};
 
 int zcache_debugfs_init(void);
 #else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
