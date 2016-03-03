Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id BC0F3828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:26:13 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id hb3so6834533igb.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:26:13 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0233.hostedemail.com. [216.40.44.233])
        by mx.google.com with ESMTPS id e71si309258ioe.91.2016.03.03.15.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 15:26:12 -0800 (PST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] mm: Coalesce split strings
Date: Thu,  3 Mar 2016 15:25:32 -0800
Message-Id: <8bc1865b2af7472be1cfc3728fe310f288083779.1457047399.git.joe@perches.com>
In-Reply-To: <cover.1457047399.git.joe@perches.com>
References: <cover.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kernel style prefers a single string over split strings when
the string is 'user-visible'.

Miscellanea:

o Add a missing newline
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/dmapool.c        | 10 ++++------
 mm/huge_memory.c    |  3 +--
 mm/kasan/report.c   |  6 ++----
 mm/kmemcheck.c      |  3 +--
 mm/kmemleak.c       | 18 ++++++++----------
 mm/memblock.c       |  3 +--
 mm/memory_hotplug.c |  3 +--
 mm/mempolicy.c      |  4 +---
 mm/mmap.c           |  8 +++-----
 mm/oom_kill.c       |  3 +--
 mm/page_alloc.c     | 37 +++++++++++++++++--------------------
 mm/page_owner.c     |  5 ++---
 mm/percpu.c         |  4 ++--
 mm/slab.c           | 28 ++++++++++------------------
 mm/slab_common.c    | 10 ++++------
 mm/slub.c           | 19 +++++++++----------
 mm/sparse-vmemmap.c |  8 ++++----
 mm/sparse.c         |  8 ++++----
 mm/swapfile.c       |  3 +--
 mm/vmalloc.c        |  4 ++--
 20 files changed, 78 insertions(+), 109 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 57312b5..2821500 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -452,13 +452,11 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 			}
 			spin_unlock_irqrestore(&pool->lock, flags);
 			if (pool->dev)
-				dev_err(pool->dev, "dma_pool_free %s, dma %Lx "
-					"already free\n", pool->name,
-					(unsigned long long)dma);
+				dev_err(pool->dev, "dma_pool_free %s, dma %Lx already free\n",
+					pool->name, (unsigned long long)dma);
 			else
-				printk(KERN_ERR "dma_pool_free %s, dma %Lx "
-					"already free\n", pool->name,
-					(unsigned long long)dma);
+				printk(KERN_ERR "dma_pool_free %s, dma %Lx already free\n",
+					pool->name, (unsigned long long)dma);
 			return;
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5b38aa2..5b4a635 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -171,8 +171,7 @@ static void set_recommended_min_free_kbytes(void)
 
 	if (recommended_min > min_free_kbytes) {
 		if (user_min_free_kbytes >= 0)
-			pr_info("raising min_free_kbytes from %d to %lu "
-				"to help transparent hugepage allocations\n",
+			pr_info("raising min_free_kbytes from %d to %lu to help transparent hugepage allocations\n",
 				min_free_kbytes, recommended_min);
 
 		min_free_kbytes = recommended_min;
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 12f222d..745aa8f 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -214,8 +214,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 	 */
 	kasan_disable_current();
 	spin_lock_irqsave(&report_lock, flags);
-	pr_err("================================="
-		"=================================\n");
+	pr_err("==================================================================\n");
 	if (info->access_addr <
 			kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
 		if ((unsigned long)info->access_addr < PAGE_SIZE)
@@ -236,8 +235,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 		print_address_description(info);
 		print_shadow_for_address(info->first_bad_addr);
 	}
-	pr_err("================================="
-		"=================================\n");
+	pr_err("==================================================================\n");
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 	spin_unlock_irqrestore(&report_lock, flags);
 	kasan_enable_current();
diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index 6f4f424..e5f8333 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -20,8 +20,7 @@ void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
 	shadow = alloc_pages_node(node, flags | __GFP_NOTRACK, order);
 	if (!shadow) {
 		if (printk_ratelimit())
-			printk(KERN_ERR "kmemcheck: failed to allocate "
-				"shadow bitmap\n");
+			printk(KERN_ERR "kmemcheck: failed to allocate shadow bitmap\n");
 		return;
 	}
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a81cd76..e642992 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -596,8 +596,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 		else if (parent->pointer + parent->size <= ptr)
 			link = &parent->rb_node.rb_right;
 		else {
-			kmemleak_stop("Cannot insert 0x%lx into the object "
-				      "search tree (overlaps existing)\n",
+			kmemleak_stop("Cannot insert 0x%lx into the object search tree (overlaps existing)\n",
 				      ptr);
 			/*
 			 * No need for parent->lock here since "parent" cannot
@@ -670,8 +669,8 @@ static void delete_object_part(unsigned long ptr, size_t size)
 	object = find_and_remove_object(ptr, 1);
 	if (!object) {
 #ifdef DEBUG
-		kmemleak_warn("Partially freeing unknown object at 0x%08lx "
-			      "(size %zu)\n", ptr, size);
+		kmemleak_warn("Partially freeing unknown object at 0x%08lx (size %zu)\n",
+			      ptr, size);
 #endif
 		return;
 	}
@@ -717,8 +716,8 @@ static void paint_ptr(unsigned long ptr, int color)
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("Trying to color unknown object "
-			      "at 0x%08lx as %s\n", ptr,
+		kmemleak_warn("Trying to color unknown object at 0x%08lx as %s\n",
+			      ptr,
 			      (color == KMEMLEAK_GREY) ? "Grey" :
 			      (color == KMEMLEAK_BLACK) ? "Black" : "Unknown");
 		return;
@@ -1463,8 +1462,8 @@ static void kmemleak_scan(void)
 	if (new_leaks) {
 		kmemleak_found_leaks = true;
 
-		pr_info("%d new suspected memory leaks (see "
-			"/sys/kernel/debug/kmemleak)\n", new_leaks);
+		pr_info("%d new suspected memory leaks (see /sys/kernel/debug/kmemleak)\n",
+			new_leaks);
 	}
 
 }
@@ -1795,8 +1794,7 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 	if (!kmemleak_found_leaks)
 		__kmemleak_do_cleanup();
 	else
-		pr_info("Kmemleak disabled without freeing internal data. "
-			"Reclaim the memory with \"echo clear > /sys/kernel/debug/kmemleak\"\n");
+		pr_info("Kmemleak disabled without freeing internal data. Reclaim the memory with \"echo clear > /sys/kernel/debug/kmemleak\".\n");
 }
 
 static DECLARE_WORK(cleanup_work, kmemleak_do_cleanup);
diff --git a/mm/memblock.c b/mm/memblock.c
index dfff740..673a2f5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -238,8 +238,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 		 * so we use WARN_ONCE() here to see the stack trace if
 		 * fail happens.
 		 */
-		WARN_ONCE(1, "memblock: bottom-up allocation failed, "
-			     "memory hotunplug may be affected\n");
+		WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
 	}
 
 	return __memblock_find_range_top_down(start, end, size, align, nid,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e62aa07..7249497 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1970,8 +1970,7 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 
 		beginpa = PFN_PHYS(section_nr_to_pfn(mem->start_section_nr));
 		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
-		pr_warn("removing memory fails, because memory "
-			"[%pa-%pa] is onlined\n",
+		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
 	}
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 26a8104..6c759ff 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2559,9 +2559,7 @@ static void __init check_numabalancing_enable(void)
 		set_numabalancing_state(numabalancing_override == 1);
 
 	if (num_online_nodes() > 1 && !numabalancing_override) {
-		pr_info("%s automatic NUMA balancing. "
-			"Configure with numa_balancing= or the "
-			"kernel.numa_balancing sysctl",
+		pr_info("%s automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl\n",
 			numabalancing_default ? "Enabling" : "Disabling");
 		set_numabalancing_state(numabalancing_default);
 	}
diff --git a/mm/mmap.c b/mm/mmap.c
index b1e3013..bd2e1a53 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2525,9 +2525,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long ret = -EINVAL;
 	struct file *file;
 
-	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. "
-			"See Documentation/vm/remap_file_pages.txt.\n",
-			current->comm, current->pid);
+	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.\n",
+		     current->comm, current->pid);
 
 	if (prot)
 		return ret;
@@ -2893,8 +2892,7 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 	if (is_data_mapping(flags) &&
 	    mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT) {
 		if (ignore_rlimit_data)
-			pr_warn_once("%s (%d): VmData %lu exceed data ulimit "
-				     "%lu. Will be forbidden soon.\n",
+			pr_warn_once("%s (%d): VmData %lu exceed data ulimit %lu. Will be forbidden soon.\n",
 				     current->comm, current->pid,
 				     (mm->data_vm + npages) << PAGE_SHIFT,
 				     rlimit(RLIMIT_DATA));
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9..e7133d7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -391,8 +391,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 static void dump_header(struct oom_control *oc, struct task_struct *p,
 			struct mem_cgroup *memcg)
 {
-	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, "
-			"oom_score_adj=%hd\n",
+	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
 		current->signal->oom_score_adj);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894..e85becb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4195,8 +4195,7 @@ static int __parse_numa_zonelist_order(char *s)
 		user_zonelist_order = ZONELIST_ORDER_ZONE;
 	} else {
 		printk(KERN_WARNING
-			"Ignoring invalid numa_zonelist_order value:  "
-			"%s\n", s);
+		       "Ignoring invalid numa_zonelist_order value:  %s\n", s);
 		return -EINVAL;
 	}
 	return 0;
@@ -4660,12 +4659,11 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 	else
 		page_group_by_mobility_disabled = 0;
 
-	pr_info("Built %i zonelists in %s order, mobility grouping %s.  "
-		"Total pages: %ld\n",
-			nr_online_nodes,
-			zonelist_order_name[current_zonelist_order],
-			page_group_by_mobility_disabled ? "off" : "on",
-			vm_total_pages);
+	pr_info("Built %i zonelists in %s order, mobility grouping %s.  Total pages: %ld\n",
+		nr_online_nodes,
+		zonelist_order_name[current_zonelist_order],
+		page_group_by_mobility_disabled ? "off" : "on",
+		vm_total_pages);
 #ifdef CONFIG_NUMA
 	pr_info("Policy zone: %s\n", zone_names[policy_zone]);
 #endif
@@ -6263,22 +6261,21 @@ void __init mem_init_print_info(const char *str)
 
 #undef	adj_init_size
 
-	pr_info("Memory: %luK/%luK available "
-	       "(%luK kernel code, %luK rwdata, %luK rodata, "
-	       "%luK init, %luK bss, %luK reserved, %luK cma-reserved"
+	pr_info("Memory: %luK/%luK available (%luK kernel code, %luK rwdata, %luK rodata, %luK init, %luK bss, %luK reserved, %luK cma-reserved"
 #ifdef	CONFIG_HIGHMEM
-	       ", %luK highmem"
+		", %luK highmem"
 #endif
-	       "%s%s)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
-	       codesize >> 10, datasize >> 10, rosize >> 10,
-	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
-	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
-	       totalcma_pages << (PAGE_SHIFT-10),
+		"%s%s)\n",
+		nr_free_pages() << (PAGE_SHIFT - 10),
+		physpages << (PAGE_SHIFT - 10),
+		codesize >> 10, datasize >> 10, rosize >> 10,
+		(init_data_size + init_code_size) >> 10, bss_size >> 10,
+		(physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT - 10),
+		totalcma_pages << (PAGE_SHIFT - 10),
 #ifdef	CONFIG_HIGHMEM
-	       totalhigh_pages << (PAGE_SHIFT-10),
+		totalhigh_pages << (PAGE_SHIFT - 10),
 #endif
-	       str ? ", " : "", str ? str : "");
+		str ? ", " : "", str ? str : "");
 }
 
 /**
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 44ad1f0..ac3d8d1 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -198,9 +198,8 @@ void __dump_page_owner(struct page *page)
 		return;
 	}
 
-	pr_alert("page allocated via order %u, migratetype %s, "
-			"gfp_mask %#x(%pGg)\n", page_ext->order,
-			migratetype_names[mt], gfp_mask, &gfp_mask);
+	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
+		 page_ext->order, migratetype_names[mt], gfp_mask, &gfp_mask);
 	print_stack_trace(&trace, 0);
 
 	if (page_ext->last_migrate_reason != -1)
diff --git a/mm/percpu.c b/mm/percpu.c
index 847814b..1571547 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -888,8 +888,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	size = ALIGN(size, 2);
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
-		WARN(true, "illegal size (%zu) or align (%zu) for "
-		     "percpu allocation\n", size, align);
+		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
+		     size, align);
 		return NULL;
 	}
 
diff --git a/mm/slab.c b/mm/slab.c
index b9ee775..7ee9532 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1565,11 +1565,9 @@ static void dump_line(char *data, int offset, int limit)
 	if (bad_count == 1) {
 		error ^= POISON_FREE;
 		if (!(error & (error - 1))) {
-			printk(KERN_ERR "Single bit error detected. Probably "
-					"bad RAM.\n");
+			printk(KERN_ERR "Single bit error detected. Probably bad RAM.\n");
 #ifdef CONFIG_X86
-			printk(KERN_ERR "Run memtest86+ or a similar memory "
-					"test tool.\n");
+			printk(KERN_ERR "Run memtest86+ or a similar memory test tool.\n");
 #else
 			printk(KERN_ERR "Run a memory test tool.\n");
 #endif
@@ -1692,11 +1690,9 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 		}
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
-				slab_error(cachep, "start of a freed object "
-					   "was overwritten");
+				slab_error(cachep, "start of a freed object was overwritten");
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
-				slab_error(cachep, "end of a freed object "
-					   "was overwritten");
+				slab_error(cachep, "end of a freed object was overwritten");
 		}
 	}
 }
@@ -2397,11 +2393,9 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
-				slab_error(cachep, "constructor overwrote the"
-					   " end of an object");
+				slab_error(cachep, "constructor overwrote the end of an object");
 			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
-				slab_error(cachep, "constructor overwrote the"
-					   " start of an object");
+				slab_error(cachep, "constructor overwrote the start of an object");
 		}
 		/* need to poison the objs? */
 		if (cachep->flags & SLAB_POISON) {
@@ -2468,8 +2462,8 @@ static void slab_put_obj(struct kmem_cache *cachep,
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
 		if (get_free_obj(page, i) == objnr) {
-			printk(KERN_ERR "slab: double free detected in cache "
-					"'%s', objp %p\n", cachep->name, objp);
+			printk(KERN_ERR "slab: double free detected in cache '%s', objp %p\n",
+			       cachep->name, objp);
 			BUG();
 		}
 	}
@@ -2900,8 +2894,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 	if (cachep->flags & SLAB_RED_ZONE) {
 		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
 				*dbg_redzone2(cachep, objp) != RED_INACTIVE) {
-			slab_error(cachep, "double free, or memory outside"
-						" object was overwritten");
+			slab_error(cachep, "double free, or memory outside object was overwritten");
 			printk(KERN_ERR
 				"%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
 				objp, *dbg_redzone1(cachep, objp),
@@ -4027,8 +4020,7 @@ void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
 		unsigned long node_frees = cachep->node_frees;
 		unsigned long overflows = cachep->node_overflow;
 
-		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu "
-			   "%4lu %4lu %4lu %4lu %4lu",
+		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu %4lu %4lu %4lu %4lu %4lu",
 			   allocs, high, grown,
 			   reaped, errors, max_freeable, node_allocs,
 			   node_frees, overflows);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8addc3c..e885e11 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -726,8 +726,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		err = shutdown_cache(s, &release, &need_rcu_barrier);
 
 	if (err) {
-		pr_err("kmem_cache_destroy %s: "
-		       "Slab cache still has objects\n", s->name);
+		pr_err("kmem_cache_destroy %s: Slab cache still has objects\n",
+		       s->name);
 		dump_stack();
 	}
 out_unlock:
@@ -1047,13 +1047,11 @@ static void print_slabinfo_header(struct seq_file *m)
 #else
 	seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
-	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
-		 "<objperslab> <pagesperslab>");
+	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
 	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
 	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #ifdef CONFIG_DEBUG_SLAB
-	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> "
-		 "<error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
+	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
 	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
 	seq_putc(m, '\n');
diff --git a/mm/slub.c b/mm/slub.c
index d86720d..d6a37eb1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -952,14 +952,14 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 		max_objects = MAX_OBJS_PER_PAGE;
 
 	if (page->objects != max_objects) {
-		slab_err(s, page, "Wrong number of objects. Found %d but "
-			"should be %d", page->objects, max_objects);
+		slab_err(s, page, "Wrong number of objects. Found %d but should be %d",
+			 page->objects, max_objects);
 		page->objects = max_objects;
 		slab_fix(s, "Number of objects adjusted.");
 	}
 	if (page->inuse != page->objects - nr) {
-		slab_err(s, page, "Wrong object count. Counter is %d but "
-			"counted were %d", page->inuse, page->objects - nr);
+		slab_err(s, page, "Wrong object count. Counter is %d but counted were %d",
+			 page->inuse, page->objects - nr);
 		page->inuse = page->objects - nr;
 		slab_fix(s, "Object count adjusted.");
 	}
@@ -1122,8 +1122,8 @@ static inline int free_consistency_checks(struct kmem_cache *s,
 
 	if (unlikely(s != page->slab_cache)) {
 		if (!PageSlab(page)) {
-			slab_err(s, page, "Attempt to free object(0x%p) "
-				"outside of slab", object);
+			slab_err(s, page, "Attempt to free object(0x%p) outside of slab",
+				 object);
 		} else if (!page->slab_cache) {
 			pr_err("SLUB <none>: no slab for object 0x%p.\n",
 			       object);
@@ -3456,10 +3456,9 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
-		panic("Cannot create slab %s size=%lu realsize=%u "
-			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)s->size, s->size,
-			oo_order(s->oo), s->offset, flags);
+		panic("Cannot create slab %s size=%lu realsize=%u order=%u offset=%u flags=%lx\n",
+		      s->name, (unsigned long)s->size, s->size,
+		      oo_order(s->oo), s->offset, flags);
 	return -EINVAL;
 }
 
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index b60802b..d3511f9 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -166,8 +166,8 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 	int actual_node = early_pfn_to_nid(pfn);
 
 	if (node_distance(actual_node, node) > LOCAL_DISTANCE)
-		printk(KERN_WARNING "[%lx-%lx] potential offnode "
-			"page_structs\n", start, end - 1);
+		printk(KERN_WARNING "[%lx-%lx] potential offnode page_structs\n",
+		       start, end - 1);
 }
 
 pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
@@ -292,8 +292,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
-		printk(KERN_ERR "%s: sparsemem memory map backing failed "
-			"some memory will not be available.\n", __func__);
+		printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+		       __func__);
 		ms->section_mem_map = 0;
 	}
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 3717cee..7cdb27d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -428,8 +428,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
-		printk(KERN_ERR "%s: sparsemem memory map backing failed "
-			"some memory will not be available.\n", __func__);
+		printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+		       __func__);
 		ms->section_mem_map = 0;
 	}
 }
@@ -456,8 +456,8 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	if (map)
 		return map;
 
-	printk(KERN_ERR "%s: sparsemem memory map backing failed "
-			"some memory will not be available.\n", __func__);
+	printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+	       __func__);
 	ms->section_mem_map = 0;
 	return NULL;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3888438..560ad38 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2532,8 +2532,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
 	enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
 
-	pr_info("Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s%s%s%s\n",
+	pr_info("Adding %uk swap on %s.  Priority:%d extents:%d across:%lluk %s%s%s%s%s\n",
 		p->pages<<(PAGE_SHIFT-10), name->name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d4b2e34..e86c24e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -469,8 +469,8 @@ overflow:
 		goto retry;
 	}
 	if (printk_ratelimit())
-		pr_warn("vmap allocation for size %lu failed: "
-			"use vmalloc=<size> to increase size.\n", size);
+		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
+			size);
 	kfree(va);
 	return ERR_PTR(-EBUSY);
 }
-- 
2.6.3.368.gf34be46

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
