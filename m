Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SHwaEx564640
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 13:58:36 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SHwaQU448704
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:58:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SHwZLm030635
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:58:35 -0600
Message-ID: <4181334B.8030703@us.ibm.com>
Date: Thu, 28 Oct 2004 10:58:35 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [3/7] 080 alloc_remap i386
References: <E1CNBE6-0006bd-0j@ladymac.shadowen.org>
In-Reply-To: <E1CNBE6-0006bd-0j@ladymac.shadowen.org>
Content-Type: multipart/mixed;
 boundary="------------070806060801030205090804"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070806060801030205090804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Removes whitespace damage.

--------------070806060801030205090804
Content-Type: text/plain;
 name="3_7_080_alloc_remap_i386-whitespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3_7_080_alloc_remap_i386-whitespace.patch"



---

 sparsemem-dave/arch/i386/mm/discontig.c |    2 +-
 sparsemem-dave/mm/page_alloc.c          |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/i386/mm/discontig.c~3_7_080_alloc_remap_i386-whitespace arch/i386/mm/discontig.c
--- sparsemem/arch/i386/mm/discontig.c~3_7_080_alloc_remap_i386-whitespace	2004-10-28 10:28:26.000000000 -0700
+++ sparsemem-dave/arch/i386/mm/discontig.c	2004-10-28 10:30:22.000000000 -0700
@@ -278,7 +278,7 @@ unsigned long __init setup_memory(void)
 		allocate_pgdat(nid);
 		printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
 			(ulong) node_remap_start_vaddr[nid],
-			(ulong) pfn_to_kaddr(highstart_pfn 
+			(ulong) pfn_to_kaddr(highstart_pfn
 			    + node_remap_offset[nid] + node_remap_size[nid]));
 	}
 	printk("High memory starts at vaddr %08lx\n",
diff -puN include/asm-i386/mmzone.h~3_7_080_alloc_remap_i386-whitespace include/asm-i386/mmzone.h
diff -puN mm/page_alloc.c~3_7_080_alloc_remap_i386-whitespace mm/page_alloc.c
--- sparsemem/mm/page_alloc.c~3_7_080_alloc_remap_i386-whitespace	2004-10-28 10:28:26.000000000 -0700
+++ sparsemem-dave/mm/page_alloc.c	2004-10-28 10:30:53.000000000 -0700
@@ -1474,7 +1474,7 @@ void zone_init_free_lists(struct pglist_
 #ifdef HAVE_ARCH_ALLOC_REMAP
 		map = (unsigned long *) alloc_remap(pgdat->node_id,
 			bitmap_size);
-		if (!map) 
+		if (!map)
 #endif
 			map = (unsigned long *) alloc_bootmem_node(pgdat,
 				bitmap_size);
_

--------------070806060801030205090804--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
