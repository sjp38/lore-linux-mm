From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Date: Thu, 29 Aug 2013 13:32:55 +0800
Message-ID: <30306.5810738646$1377754403@news.gmane.org>
References: <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
 <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
 <521600cc.22ab440a.2703.53f1SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQXrpZU8DCFoF6NuaOoqwGFGcQfnHV7vdWWPfyAymCCGnQ@mail.gmail.com>
 <CAE9FiQU34RC+4uLpeza4PAAK-1CWu82WQ=rhaM_NNj_TVv0EMg@mail.gmail.com>
 <CAE9FiQVPmjxCzOCPQWz4=6JwzB-Vn5YMtOEd-G97SvEgoY3RQg@mail.gmail.com>
 <521eb73e.e3bf420a.2ad0.09c2SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQWV2m6MvRXFAXMYr-D0RSEj9vXiKBQhp5LmzpJFEizyww@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VEur5-0000S6-7n
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Aug 2013 07:33:15 +0200
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 106936B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 01:33:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Aug 2013 15:29:49 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4DC852CE8059
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:33:05 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7T5GhB48782096
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:16:49 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7T5WvOq002050
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:32:58 +1000
Content-Disposition: inline
In-Reply-To: <CAE9FiQWV2m6MvRXFAXMYr-D0RSEj9vXiKBQhp5LmzpJFEizyww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 28, 2013 at 09:10:25PM -0700, Yinghai Lu wrote:
>On Wed, Aug 28, 2013 at 7:51 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> Hi Yinghai,
>>>> looks like that is what is your first version did.
>>>>
>>>> I updated it a little bit. please check it.
>>>>
>>>
>>>removed more lines.
>>
>> Thanks for your great work!
>>
>> The fixed patch looks good to me. If this is the last fix and I can
>> ignore http://marc.info/?l=linux-mm&m=137774271220239&w=2?
>
>Yes, you can ignore that.

Thanks, a little adjustment to fix compile warning. 

>
>Yinghai

Hi Andrew,

The patch in attachment is rebased on mm-sparse-introduce-alloc_usemap_and_memmap-fix.patch,
Could you pick this one?



--ibTvN161/egqYuK8
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sparse.patch"

>From b69866fb1baa9963daf91e66fb9826d6f62879fe Mon Sep 17 00:00:00 2001
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Date: Thu, 29 Aug 2013 12:34:17 +0800
Subject: [PATCH] mm/sparse: introduce alloc_usemap_and_memmap fix-2

Pass function pointer to alloc_usemap_and_memmap() instead of true/false.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/sparse.c | 41 +++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 3bb221a..6734d56 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -339,13 +339,14 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
+static void __init sparse_early_usemaps_alloc_node(void **data,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
 				 unsigned long usemap_count, int nodeid)
 {
 	void *usemap;
 	unsigned long pnum;
+	unsigned long **usemap_map = (unsigned long **)data;
 	int size = usemap_size();
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
@@ -430,23 +431,16 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
+static void __init sparse_early_mem_maps_alloc_node(void **data,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
 				 unsigned long map_count, int nodeid)
 {
+	struct page **map_map = (struct page **)data;
 	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
 					 map_count, nodeid);
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
@@ -471,9 +465,10 @@ void __attribute__((weak)) __meminit vmemmap_populate_print_last(void)
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
  *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
- *  @use_map: true if memory allocated for pageblock flags, otherwise false
  */
-static void __init alloc_usemap_and_memmap(unsigned long **map, bool use_map)
+static void __init alloc_usemap_and_memmap(void (*alloc_func)
+					(void **, unsigned long, unsigned long,
+					unsigned long, int), void **data)
 {
 	unsigned long pnum;
 	unsigned long map_count;
@@ -504,24 +499,16 @@ static void __init alloc_usemap_and_memmap(unsigned long **map, bool use_map)
 			continue;
 		}
 		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		if (use_map)
-			sparse_early_usemaps_alloc_node(map, pnum_begin, pnum,
-						 map_count, nodeid_begin);
-		else
-			sparse_early_mem_maps_alloc_node((struct page **)map,
-				pnum_begin, pnum, map_count, nodeid_begin);
+		alloc_func(data, pnum_begin, pnum,
+						map_count, nodeid_begin);
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
+	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
+						map_count, nodeid_begin);
 }
 
 /*
@@ -561,14 +548,16 @@ void __init sparse_init(void)
 	usemap_map = alloc_bootmem(size);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
-	alloc_usemap_and_memmap(usemap_map, true);
+	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
+							(void **)usemap_map);
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
 	map_map = alloc_bootmem(size2);
 	if (!map_map)
 		panic("can not allocate map_map\n");
-	alloc_usemap_and_memmap((unsigned long **)map_map, false);
+	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
+							(void **)map_map);
 #endif
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-- 
1.8.1.2


--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
