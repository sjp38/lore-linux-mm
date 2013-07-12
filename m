Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 536286B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 23:28:08 -0400 (EDT)
Message-ID: <51DF778B.8090701@asianux.com>
Date: Fri, 12 Jul 2013 11:27:07 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/slub.c: beautify code of this file
References: <51DF5F43.3080408@asianux.com>
In-Reply-To: <51DF5F43.3080408@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com
Cc: linux-mm@kvack.org

Be sure of 80 column limitation for both code and comments.

Correct tab alignment for 'if-else' statement.

Remove redundancy 'break' statement.

Remove useless BUG_ON(), since it can never happen.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |   94 ++++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 56 insertions(+), 38 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..2b02d64 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -373,7 +373,8 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 #endif
 	{
 		slab_lock(page);
-		if (page->freelist == freelist_old && page->counters == counters_old) {
+		if (page->freelist == freelist_old &&
+					page->counters == counters_old) {
 			page->freelist = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
@@ -411,7 +412,8 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 
 		local_irq_save(flags);
 		slab_lock(page);
-		if (page->freelist == freelist_old && page->counters == counters_old) {
+		if (page->freelist == freelist_old &&
+					page->counters == counters_old) {
 			page->freelist = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
@@ -553,8 +555,9 @@ static void print_tracking(struct kmem_cache *s, void *object)
 
 static void print_page_info(struct page *page)
 {
-	printk(KERN_ERR "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-		page, page->objects, page->inuse, page->freelist, page->flags);
+	printk(KERN_ERR
+	       "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
+	       page, page->objects, page->inuse, page->freelist, page->flags);
 
 }
 
@@ -629,7 +632,8 @@ static void object_err(struct kmem_cache *s, struct page *page,
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...)
+static void slab_err(struct kmem_cache *s, struct page *page,
+			const char *fmt, ...)
 {
 	va_list args;
 	char buf[100];
@@ -788,7 +792,8 @@ static int check_object(struct kmem_cache *s, struct page *page,
 	} else {
 		if ((s->flags & SLAB_POISON) && s->object_size < s->inuse) {
 			check_bytes_and_report(s, page, p, "Alignment padding",
-				endobject, POISON_INUSE, s->inuse - s->object_size);
+				endobject, POISON_INUSE,
+				s->inuse - s->object_size);
 		}
 	}
 
@@ -881,7 +886,6 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 				slab_fix(s, "Freelist cleared");
 				return 0;
 			}
-			break;
 		}
 		object = fp;
 		fp = get_freepointer(s, object);
@@ -918,7 +922,8 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 			page->freelist);
 
 		if (!alloc)
-			print_section("Object ", (void *)object, s->object_size);
+			print_section("Object ", (void *)object,
+					s->object_size);
 
 		dump_stack();
 	}
@@ -937,7 +942,8 @@ static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 	return should_failslab(s->object_size, flags, s->flags);
 }
 
-static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
+static inline void slab_post_alloc_hook(struct kmem_cache *s,
+					gfp_t flags, void *object)
 {
 	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
@@ -1039,7 +1045,8 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
-static noinline int alloc_debug_processing(struct kmem_cache *s, struct page *page,
+static noinline int alloc_debug_processing(struct kmem_cache *s,
+					struct page *page,
 					void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
@@ -1743,7 +1750,8 @@ static void init_kmem_cache_cpus(struct kmem_cache *s)
 /*
  * Remove the cpu slab
  */
-static void deactivate_slab(struct kmem_cache *s, struct page *page, void *freelist)
+static void deactivate_slab(struct kmem_cache *s, struct page *page,
+				void *freelist)
 {
 	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
@@ -2002,7 +2010,8 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		page->pobjects = pobjects;
 		page->next = oldpage;
 
-	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
+	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
+								!= oldpage);
 #endif
 }
 
@@ -2172,8 +2181,8 @@ static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags)
 }
 
 /*
- * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
- * or deactivate the page.
+ * Check the page->freelist of a page and either transfer the freelist to the
+ * per cpu freelist or deactivate the page.
  *
  * The page is still frozen if the return value is not NULL.
  *
@@ -2317,7 +2326,8 @@ new_slab:
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (kmem_cache_debug(s) && !alloc_debug_processing(s, page, freelist, addr))
+	if (kmem_cache_debug(s) &&
+			!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
 	deactivate_slab(s, page, get_freepointer(s, freelist));
@@ -2385,13 +2395,15 @@ redo:
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
 		 *
-		 * The cmpxchg does the following atomically (without lock semantics!)
+		 * The cmpxchg does the following atomically (without lock
+		 * semantics!)
 		 * 1. Relocate first pointer to the current per cpu area.
 		 * 2. Verify that tid and freelist have not been changed
 		 * 3. If they were not changed replace tid and freelist
 		 *
-		 * Since this is without lock semantics the protection is only against
-		 * code executing on this cpu *not* from access by other cpus.
+		 * Since this is without lock semantics the protection is only
+		 * against code executing on this cpu *not* from access by
+		 * other cpus.
 		 */
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
@@ -2423,7 +2435,8 @@ void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 
-	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, gfpflags);
+	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size,
+				s->size, gfpflags);
 
 	return ret;
 }
@@ -2515,8 +2528,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 			if (kmem_cache_has_cpu_partial(s) && !prior)
 
 				/*
-				 * Slab was on no list before and will be partially empty
-				 * We can defer the list move and instead freeze it.
+				 * Slab was on no list before and will be
+				 * partially empty
+				 * We can defer the list move and instead
+				 * freeze it.
 				 */
 				new.frozen = 1;
 
@@ -3074,8 +3089,8 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	 * A) The number of objects from per cpu partial slabs dumped to the
 	 *    per node list when we reach the limit.
 	 * B) The number of objects in cpu partial slabs to extract from the
-	 *    per node list when we run out of per cpu objects. We only fetch 50%
-	 *    to keep some capacity around for frees.
+	 *    per node list when we run out of per cpu objects. We only fetch
+	 *    50% to keep some capacity around for frees.
 	 */
 	if (!kmem_cache_has_cpu_partial(s))
 		s->cpu_partial = 0;
@@ -3102,8 +3117,8 @@ error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
 			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)s->size, s->size, oo_order(s->oo),
-			s->offset, flags);
+			s->name, (unsigned long)s->size, s->size,
+			oo_order(s->oo), s->offset, flags);
 	return -EINVAL;
 }
 
@@ -3341,7 +3356,8 @@ bool verify_mem_not_deleted(const void *x)
 
 	slab_lock(page);
 	if (on_freelist(page->slab_cache, page, object)) {
-		object_err(page->slab_cache, page, object, "Object is on free-list");
+		object_err(page->slab_cache, page, object,
+				"Object is on free-list");
 		rv = false;
 	} else {
 		rv = true;
@@ -4165,15 +4181,17 @@ static int list_locations(struct kmem_cache *s, char *buf,
 				!cpumask_empty(to_cpumask(l->cpus)) &&
 				len < PAGE_SIZE - 60) {
 			len += sprintf(buf + len, " cpus=");
-			len += cpulist_scnprintf(buf + len, PAGE_SIZE - len - 50,
+			len += cpulist_scnprintf(buf + len,
+						 PAGE_SIZE - len - 50,
 						 to_cpumask(l->cpus));
 		}
 
 		if (nr_online_nodes > 1 && !nodes_empty(l->nodes) &&
 				len < PAGE_SIZE - 60) {
 			len += sprintf(buf + len, " nodes=");
-			len += nodelist_scnprintf(buf + len, PAGE_SIZE - len - 50,
-					l->nodes);
+			len += nodelist_scnprintf(buf + len,
+						  PAGE_SIZE - len - 50,
+						  l->nodes);
 		}
 
 		len += sprintf(buf + len, "\n");
@@ -4282,7 +4300,8 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		int cpu;
 
 		for_each_possible_cpu(cpu) {
-			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab,
+							       cpu);
 			int node;
 			struct page *page;
 
@@ -4318,12 +4337,11 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
 
-		if (flags & SO_TOTAL)
-			x = atomic_long_read(&n->total_objects);
-		else if (flags & SO_OBJECTS)
-			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
-
+			if (flags & SO_TOTAL)
+				x = atomic_long_read(&n->total_objects);
+			else if (flags & SO_OBJECTS)
+				x = atomic_long_read(&n->total_objects) -
+					count_partial(n, count_free);
 			else
 				x = atomic_long_read(&n->nr_slabs);
 			total += x;
@@ -5139,10 +5157,10 @@ static char *create_unique_id(struct kmem_cache *s)
 
 #ifdef CONFIG_MEMCG_KMEM
 	if (!is_root_cache(s))
-		p += sprintf(p, "-%08d", memcg_cache_id(s->memcg_params->memcg));
+		p += sprintf(p, "-%08d",
+				memcg_cache_id(s->memcg_params->memcg));
 #endif
 
-	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
