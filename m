Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SHxR1p157618
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 13:59:27 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SHxQQU459982
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:59:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SHxQ1o000910
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:59:26 -0600
Message-ID: <4181337D.4000702@us.ibm.com>
Date: Thu, 28 Oct 2004 10:59:25 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [3/7] 080 alloc_remap i386
References: <E1CNBE6-0006bd-0j@ladymac.shadowen.org>
In-Reply-To: <E1CNBE6-0006bd-0j@ladymac.shadowen.org>
Content-Type: multipart/mixed;
 boundary="------------050103080100070207020202"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050103080100070207020202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This should get rid of the #ifdefs surround the alloc_remap() calls. 
Compiles on non-discontig i386.

--------------050103080100070207020202
Content-Type: text/plain;
 name="3_7_080_alloc_remap_i386-removeifdefs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3_7_080_alloc_remap_i386-removeifdefs.patch"



---

 sparsemem-dave/include/linux/bootmem.h |    9 +++++++++
 1 files changed, 9 insertions(+)

diff -puN arch/i386/mm/discontig.c~3_7_080_alloc_remap_i386-removeifdefs arch/i386/mm/discontig.c
diff -puN include/asm-i386/mmzone.h~3_7_080_alloc_remap_i386-removeifdefs include/asm-i386/mmzone.h
diff -puN mm/page_alloc.c~3_7_080_alloc_remap_i386-removeifdefs mm/page_alloc.c
diff -puN include/linux/mmzone.h~3_7_080_alloc_remap_i386-removeifdefs include/linux/mmzone.h
diff -L linux/bootmem.h -puN /dev/null /dev/null
diff -puN include/linux/bootmem.h~3_7_080_alloc_remap_i386-removeifdefs include/linux/bootmem.h
--- sparsemem/include/linux/bootmem.h~3_7_080_alloc_remap_i386-removeifdefs	2004-10-28 10:39:14.000000000 -0700
+++ sparsemem-dave/include/linux/bootmem.h	2004-10-28 10:44:04.000000000 -0700
@@ -67,6 +67,15 @@ extern void * __init __alloc_bootmem_nod
 	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
+#ifdef HAVE_ARCH_ALLOC_REMAP
+extern void *alloc_remap(int nid, unsigned long size);
+#else
+static inline void *alloc_remap(int nid, unsigned long size)
+{
+	return NULL;
+}
+#endif
+
 extern unsigned long __initdata nr_kernel_pages;
 extern unsigned long __initdata nr_all_pages;
 
_

--------------050103080100070207020202--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
