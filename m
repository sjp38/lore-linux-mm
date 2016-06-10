Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB066B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 23:47:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so93407262pfa.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 20:47:58 -0700 (PDT)
Received: from out1134-218.mail.aliyun.com (out1134-218.mail.aliyun.com. [42.120.134.218])
        by mx.google.com with ESMTP id sq4si10972602pab.243.2016.06.09.20.47.56
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 20:47:56 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH trivial] include/linux/memory_hotplug.h: Clean up code
Date: Fri, 10 Jun 2016 11:47:42 +0800
Message-Id: <1465530462-8285-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, trivial@kernel.org
Cc: mhocko@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, baiyaowei@cmss.chinamobile.com, vkuznets@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

Use one line instead of two lines for pgdat_resize_init, since one line
is still within 80 columns.

Let the second line function parameter almost align with the first line
parameter.

Use pr_warn instead of printk, so also let the line within 80 columns.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 include/linux/memory_hotplug.h | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 01033fa..714f3ea 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -48,8 +48,7 @@ void pgdat_resize_unlock(struct pglist_data *pgdat, unsigned long *flags)
 {
 	spin_unlock_irqrestore(&pgdat->node_size_lock, *flags);
 }
-static inline
-void pgdat_resize_init(struct pglist_data *pgdat)
+static inline void pgdat_resize_init(struct pglist_data *pgdat)
 {
 	spin_lock_init(&pgdat->node_size_lock);
 }
@@ -105,12 +104,12 @@ extern bool memhp_auto_online;
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages);
+			unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages);
+			unsigned long nr_pages);
 
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
@@ -223,7 +222,7 @@ static inline void zone_seqlock_init(struct zone *zone) {}
 
 static inline int mhp_notimplemented(const char *func)
 {
-	printk(KERN_WARNING "%s() called, with CONFIG_MEMORY_HOTPLUG disabled\n", func);
+	pr_warn("%s() called, with CONFIG_MEMORY_HOTPLUG disabled\n", func);
 	dump_stack();
 	return -ENOSYS;
 }
@@ -270,18 +269,18 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
-		void *arg, int (*func)(struct memory_block *, void *));
+			void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
-		bool for_device);
+			bool for_device);
 extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset);
+					unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
