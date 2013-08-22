From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Date: Thu, 22 Aug 2013 20:14:52 +0800
Message-ID: <45249.6540420272$1377173716@news.gmane.org>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
 <CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
 <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
 <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
 <20130822120809.GA6489@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VCTn7-0005so-MP
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Aug 2013 14:15:06 +0200
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 871766B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 08:15:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 22:04:34 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 761A3357804E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:56 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7MCEiSg60620894
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:45 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7MCEs3a022020
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:55 +1000
Content-Disposition: inline
In-Reply-To: <20130822120809.GA6489@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 22, 2013 at 08:08:09PM +0800, Wanpeng Li wrote:
>On Wed, Aug 21, 2013 at 10:19:52PM -0700, Yinghai Lu wrote:
>>On Wed, Aug 21, 2013 at 12:29 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>>> Hi Yinghai,
>>> On Tue, Aug 20, 2013 at 09:28:29PM -0700, Yinghai Lu wrote:
>>>>On Tue, Aug 20, 2013 at 8:11 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>>>>> Hi Yinghai,
>>>>> On Tue, Aug 20, 2013 at 05:02:17PM -0700, Yinghai Lu wrote:
>>>>>>>> -     /* ok, last chunk */
>>>>>>>> -     sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>>>>>>>> -                                      usemap_count, nodeid_begin);
>>>>>>>> +     alloc_usemap_and_memmap(usemap_map, true);
>>>>>>
>>>>>>alloc_usemap_and_memmap() is somehow confusing.
>>>>>>
>>>>>>Please check if you can pass function pointer instead of true/false.
>>>>>>
>>>>>
>>>>> sparse_early_usemaps_alloc_node and sparse_early_mem_maps_alloc_node is
>>>>> similar, however, one has a parameter unsigned long ** and the other has
>>>>> struct page **. function pointer can't help, isn't it? ;-)
>>>>
>>>>you could have one generic function pointer like
>>>>void *alloc_func(void *data);
>>>>
>>>>and in the every alloc function, have own struct data to pass in/out...
>>>>
>

Sorry send you the wrong version, how about this one?



--bp/iNruPH9dso1Pn
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-2.patch"

>From f21640b6dc15c76ac10fccada96e6b9fdce5a092 Mon Sep 17 00:00:00 2001
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Date: Thu, 22 Aug 2013 19:57:54 +0800
Subject: [PATCH] mm/sparse: introduce alloc_usemap_and_memmap fix

Pass function pointer to alloc_usemap_and_memmap() instead of true/false.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/sparse.c | 78 ++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 44 insertions(+), 34 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 55e5752..22a1a26 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -14,6 +14,14 @@
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 
+struct alloc_info {
+	unsigned long **map_map;
+	unsigned long pnum_begin;
+	unsigned long pnum_end;
+	unsigned long map_count;
+	int nodeid;
+};
+
 /*
  * Permanent SPARSEMEM data:
  *
@@ -339,13 +347,16 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
-				 unsigned long pnum_begin,
-				 unsigned long pnum_end,
-				 unsigned long usemap_count, int nodeid)
+static void __init sparse_early_usemaps_alloc_node(void *data)
 {
 	void *usemap;
 	unsigned long pnum;
+	struct alloc_info *info = (struct alloc_info *)data;
+	unsigned long **usemap_map = info->map_map;
+	unsigned long pnum_begin = info->pnum_begin;
+	unsigned long pnum_end = info->pnum_end;
+	unsigned long usemap_count = info->map_count;
+	int nodeid = info->nodeid;
 	int size = usemap_size();
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
@@ -430,23 +441,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
-				 unsigned long pnum_begin,
-				 unsigned long pnum_end,
-				 unsigned long map_count, int nodeid)
+static void __init sparse_early_mem_maps_alloc_node(void *data)
 {
-	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
-					 map_count, nodeid);
+	struct alloc_info *info = (struct alloc_info *)data;
+	sparse_mem_maps_populate_node((struct page **)info->map_map,
+	info->pnum_begin, info->pnum_end, info->map_count, info->nodeid);
 }
 #else
-
-static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
-				unsigned long pnum_begin,
-				unsigned long pnum_end,
-				unsigned long map_count, int nodeid)
-{
-}
-
 static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -471,14 +472,15 @@ void __attribute__((weak)) __meminit vmemmap_populate_print_last(void)
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
  *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
- *  @use_map: true if memory allocated for pageblock flags, otherwise false
  */
-static void alloc_usemap_and_memmap(unsigned long **map, bool use_map)
+static void alloc_usemap_and_memmap(void (*sparse_early_maps_alloc_node)
+				(void *data), void *data)
 {
 	unsigned long pnum;
 	unsigned long map_count;
 	int nodeid_begin = 0;
 	unsigned long pnum_begin = 0;
+	struct alloc_info *info = (struct alloc_info *)data;
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		struct mem_section *ms;
@@ -503,25 +505,24 @@ static void alloc_usemap_and_memmap(unsigned long **map, bool use_map)
 			map_count++;
 			continue;
 		}
+
+		info->pnum_begin = pnum_begin;
+		info->pnum_end = pnum;
+		info->map_count = map_count;
+		info->nodeid = nodeid_begin;
 		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		if (use_map)
-			sparse_early_usemaps_alloc_node(map, pnum_begin, pnum,
-						 map_count, nodeid_begin);
-		else
-			sparse_early_mem_maps_alloc_node((struct page **)map,
-				pnum_begin, pnum, map_count, nodeid_begin);
+		sparse_early_maps_alloc_node((void *)info);
 		/* new start, update count etc*/
 		nodeid_begin = nodeid;
 		pnum_begin = pnum;
 		map_count = 1;
 	}
 	/* ok, last chunk */
-	if (use_map)
-		sparse_early_usemaps_alloc_node(map, pnum_begin,
-				NR_MEM_SECTIONS, map_count, nodeid_begin);
-	else
-		sparse_early_mem_maps_alloc_node((struct page **)map,
-			pnum_begin, NR_MEM_SECTIONS, map_count, nodeid_begin);
+	info->pnum_begin = pnum_begin;
+	info->pnum_end = NR_MEM_SECTIONS;
+	info->map_count = map_count;
+	info->nodeid = nodeid_begin;
+	sparse_early_maps_alloc_node((void *)info);
 }
 
 /*
@@ -535,11 +536,14 @@ void __init sparse_init(void)
 	unsigned long *usemap;
 	unsigned long **usemap_map;
 	int size;
+	struct alloc_info data;
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	int size2;
 	struct page **map_map;
 #endif
 
+	void (*sparse_early_maps_alloc_node)(void *data);
+
 	/* see include/linux/mmzone.h 'struct mem_section' definition */
 	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
 
@@ -561,14 +565,20 @@ void __init sparse_init(void)
 	usemap_map = alloc_bootmem(size);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
-	alloc_usemap_and_memmap(usemap_map, true);
+	sparse_early_maps_alloc_node = sparse_early_usemaps_alloc_node;
+	data.map_map = usemap_map;
+	alloc_usemap_and_memmap(sparse_early_maps_alloc_node, (void *)&data);
+	usemap_map = data.map_map;
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
 	map_map = alloc_bootmem(size2);
 	if (!map_map)
 		panic("can not allocate map_map\n");
-	alloc_usemap_and_memmap((unsigned long **)map_map, false);
+	sparse_early_maps_alloc_node = sparse_early_mem_maps_alloc_node;
+	data.map_map = (unsigned long **)map_map;
+	alloc_usemap_and_memmap(sparse_early_maps_alloc_node, (void *)&data);
+	map_map = (struct page **)data.map_map;
 #endif
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-- 
1.8.1.2


--bp/iNruPH9dso1Pn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
