Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id B7878828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:26:02 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id i18so6776901igh.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:26:02 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0077.hostedemail.com. [216.40.44.77])
        by mx.google.com with ESMTPS id cz15si634432igc.81.2016.03.03.15.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 15:26:02 -0800 (PST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] mm: Convert pr_warning to pr_warn
Date: Thu,  3 Mar 2016 15:25:31 -0800
Message-Id: <4d7b3004d1715ddf86c821527a334615ac2dfdf4.1457047399.git.joe@perches.com>
In-Reply-To: <cover.1457047399.git.joe@perches.com>
References: <cover.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are a mixture of pr_warning and pr_warn uses in mm.
Use pr_warn consistently.

Miscellanea:

o Coalesce formats
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/hugetlb.c  |  9 ++++-----
 mm/kmemleak.c | 14 +++++++-------
 mm/percpu.c   | 15 +++++++--------
 3 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 01f2b48..547e429 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2665,7 +2665,7 @@ void __init hugetlb_add_hstate(unsigned int order)
 	unsigned long i;
 
 	if (size_to_hstate(PAGE_SIZE << order)) {
-		pr_warning("hugepagesz= specified twice, ignoring\n");
+		pr_warn("hugepagesz= specified twice, ignoring\n");
 		return;
 	}
 	BUG_ON(hugetlb_max_hstate >= HUGE_MAX_HSTATE);
@@ -2701,8 +2701,7 @@ static int __init hugetlb_nrpages_setup(char *s)
 		mhp = &parsed_hstate->max_huge_pages;
 
 	if (mhp == last_mhp) {
-		pr_warning("hugepages= specified twice without "
-			   "interleaving hugepagesz=, ignoring\n");
+		pr_warn("hugepages= specified twice without interleaving hugepagesz=, ignoring\n");
 		return 1;
 	}
 
@@ -3502,8 +3501,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * COW. Warn that such a situation has occurred as it may not be obvious
 	 */
 	if (is_vma_resv_set(vma, HPAGE_RESV_UNMAPPED)) {
-		pr_warning("PID %d killed due to inadequate hugepage pool\n",
-			   current->pid);
+		pr_warn("PID %d killed due to inadequate hugepage pool\n",
+			current->pid);
 		return ret;
 	}
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 25c0ad3..a81cd76 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -276,7 +276,7 @@ static void kmemleak_disable(void);
  * Print a warning and dump the stack trace.
  */
 #define kmemleak_warn(x...)	do {		\
-	pr_warning(x);				\
+	pr_warn(x);				\
 	dump_stack();				\
 	kmemleak_warning = 1;			\
 } while (0)
@@ -543,7 +543,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
 	if (!object) {
-		pr_warning("Cannot allocate a kmemleak_object structure\n");
+		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
 		return NULL;
 	}
@@ -764,7 +764,7 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 
 	area = kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
 	if (!area) {
-		pr_warning("Cannot allocate a scan area\n");
+		pr_warn("Cannot allocate a scan area\n");
 		goto out;
 	}
 
@@ -1515,7 +1515,7 @@ static void start_scan_thread(void)
 		return;
 	scan_thread = kthread_run(kmemleak_scan_thread, NULL, "kmemleak");
 	if (IS_ERR(scan_thread)) {
-		pr_warning("Failed to create the scan thread\n");
+		pr_warn("Failed to create the scan thread\n");
 		scan_thread = NULL;
 	}
 }
@@ -1874,8 +1874,8 @@ void __init kmemleak_init(void)
 	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
 
 	if (crt_early_log > ARRAY_SIZE(early_log))
-		pr_warning("Early log buffer exceeded (%d), please increase "
-			   "DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n", crt_early_log);
+		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n",
+			crt_early_log);
 
 	/* the kernel is still in UP mode, so disabling the IRQs is enough */
 	local_irq_save(flags);
@@ -1960,7 +1960,7 @@ static int __init kmemleak_late_init(void)
 	dentry = debugfs_create_file("kmemleak", S_IRUGO, NULL, NULL,
 				     &kmemleak_fops);
 	if (!dentry)
-		pr_warning("Failed to create the debugfs kmemleak file\n");
+		pr_warn("Failed to create the debugfs kmemleak file\n");
 	mutex_lock(&scan_mutex);
 	start_scan_thread();
 	mutex_unlock(&scan_mutex);
diff --git a/mm/percpu.c b/mm/percpu.c
index 998607a..847814b 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1033,8 +1033,8 @@ fail_unlock:
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 fail:
 	if (!is_atomic && warn_limit) {
-		pr_warning("PERCPU: allocation failed, size=%zu align=%zu atomic=%d, %s\n",
-			   size, align, is_atomic, err);
+		pr_warn("PERCPU: allocation failed, size=%zu align=%zu atomic=%d, %s\n",
+			size, align, is_atomic, err);
 		dump_stack();
 		if (!--warn_limit)
 			pr_info("PERCPU: limit reached, disable warning\n");
@@ -1723,7 +1723,7 @@ static int __init percpu_alloc_setup(char *str)
 		pcpu_chosen_fc = PCPU_FC_PAGE;
 #endif
 	else
-		pr_warning("PERCPU: unknown allocator %s specified\n", str);
+		pr_warn("PERCPU: unknown allocator %s specified\n", str);
 
 	return 0;
 }
@@ -2016,9 +2016,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 
 	/* warn if maximum distance is further than 75% of vmalloc space */
 	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
-		pr_warning("PERCPU: max_distance=0x%zx too large for vmalloc "
-			   "space 0x%lx\n", max_distance,
-			   VMALLOC_TOTAL);
+		pr_warn("PERCPU: max_distance=0x%zx too large for vmalloc space 0x%lx\n",
+			max_distance, VMALLOC_TOTAL);
 #ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
 		/* and fail if we have fallback */
 		rc = -EINVAL;
@@ -2100,8 +2099,8 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 
 			ptr = alloc_fn(cpu, PAGE_SIZE, PAGE_SIZE);
 			if (!ptr) {
-				pr_warning("PERCPU: failed to allocate %s page "
-					   "for cpu%u\n", psize_str, cpu);
+				pr_warn("PERCPU: failed to allocate %s page for cpu%u\n",
+					psize_str, cpu);
 				goto enomem;
 			}
 			/* kmemleak tracks the percpu allocations separately */
-- 
2.6.3.368.gf34be46

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
