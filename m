Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 717FB6B00DD
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 18:31:33 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so8918114pdj.34
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 15:31:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.125])
        by mx.google.com with SMTP id u9si43512pbf.143.2013.10.22.15.31.31
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 15:31:32 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 23/24] mm: Convert use of typedef ctl_table to struct ctl_table
Date: Tue, 22 Oct 2013 15:30:06 -0700
Message-Id: <4dd4d6fc0ddffaaa0bbffb484d7ce39c41416cee.1382480758.git.joe@perches.com>
In-Reply-To: <cover.1382480758.git.joe@perches.com>
References: <cover.1382480758.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page-writeback.c |  2 +-
 mm/page_alloc.c     | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f5236f8..bd0a03f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1687,7 +1687,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 /*
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
-int dirty_writeback_centisecs_handler(ctl_table *table, int write,
+int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec(table, write, buffer, length, ppos);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1cf5f8..5a9a0d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3314,7 +3314,7 @@ early_param("numa_zonelist_order", setup_numa_zonelist_order);
 /*
  * sysctl handler for numa_zonelist_order
  */
-int numa_zonelist_order_handler(ctl_table *table, int write,
+int numa_zonelist_order_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *length,
 		loff_t *ppos)
 {
@@ -5698,7 +5698,7 @@ module_init(init_per_zone_wmark_min)
  *	that we can call two helper functions whenever min_free_kbytes
  *	changes.
  */
-int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
+int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec(table, write, buffer, length, ppos);
@@ -5710,7 +5710,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 }
 
 #ifdef CONFIG_NUMA
-int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
+int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
@@ -5726,7 +5726,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
+int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
@@ -5752,7 +5752,7 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  * minimum watermarks. The lowmem reserve ratio can only make sense
  * if in function of the boot time zone sizes.
  */
-int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
+int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
@@ -5765,7 +5765,7 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
  * cpu.  It is the fraction of total pages in each zone that a hot per cpu
  * pagelist can have before it gets flushed back to buddy allocator.
  */
-int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
+int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
