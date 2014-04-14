Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id A866C6B00CB
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 21:56:50 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so2865338igb.14
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 18:56:50 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0195.hostedemail.com. [216.40.44.195])
        by mx.google.com with ESMTP id nv5si10598106igb.41.2014.04.13.18.56.49
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 18:56:50 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 3.16 18/19] mm: Convert use of typedef ctl_table to struct ctl_table
Date: Sun, 13 Apr 2014 18:55:50 -0700
Message-Id: <ea251e288bc8a4882a55fe5a1ad1f7a09abd5be0.1397438826.git.joe@perches.com>
In-Reply-To: <cover.1397438826.git.joe@perches.com>
References: <cover.1397438826.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page-writeback.c |  2 +-
 mm/page_alloc.c     | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ef41349..023cf08 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1682,7 +1682,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 /*
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
-int dirty_writeback_centisecs_handler(ctl_table *table, int write,
+int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec(table, write, buffer, length, ppos);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..0128d50 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3351,7 +3351,7 @@ early_param("numa_zonelist_order", setup_numa_zonelist_order);
 /*
  * sysctl handler for numa_zonelist_order
  */
-int numa_zonelist_order_handler(ctl_table *table, int write,
+int numa_zonelist_order_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *length,
 		loff_t *ppos)
 {
@@ -5774,7 +5774,7 @@ module_init(init_per_zone_wmark_min)
  *	that we can call two helper functions whenever min_free_kbytes
  *	changes.
  */
-int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
+int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	int rc;
@@ -5791,7 +5791,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 }
 
 #ifdef CONFIG_NUMA
-int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
+int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
@@ -5807,7 +5807,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
+int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
@@ -5833,7 +5833,7 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  * minimum watermarks. The lowmem reserve ratio can only make sense
  * if in function of the boot time zone sizes.
  */
-int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
+int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
@@ -5846,7 +5846,7 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
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
