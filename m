Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC4F6B0255
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:09:41 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so141974186qkh.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:09:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n78si25275827qgn.13.2015.07.07.08.09.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:09:40 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:09:38 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 1/7] mm/vmalloc: export __vmalloc_node_flags
In-Reply-To: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1507071109030.23387@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <msnitzer@redhat.com>
Cc: "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com

Export the function __vmalloc_node_flags.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-4.1/include/linux/vmalloc.h
===================================================================
--- linux-4.1.orig/include/linux/vmalloc.h	2015-07-02 19:19:43.000000000 +0200
+++ linux-4.1/include/linux/vmalloc.h	2015-07-02 19:20:59.000000000 +0200
@@ -75,6 +75,7 @@ extern void *vmalloc_exec(unsigned long 
 extern void *vmalloc_32(unsigned long size);
 extern void *vmalloc_32_user(unsigned long size);
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
+void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
Index: linux-4.1/mm/vmalloc.c
===================================================================
--- linux-4.1.orig/mm/vmalloc.c	2015-07-02 19:19:13.000000000 +0200
+++ linux-4.1/mm/vmalloc.c	2015-07-02 19:21:00.000000000 +0200
@@ -1722,12 +1722,12 @@ void *__vmalloc(unsigned long size, gfp_
 }
 EXPORT_SYMBOL(__vmalloc);
 
-static inline void *__vmalloc_node_flags(unsigned long size,
-					int node, gfp_t flags)
+void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags)
 {
 	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
 					node, __builtin_return_address(0));
 }
+EXPORT_SYMBOL(__vmalloc_node_flags);
 
 /**
  *	vmalloc  -  allocate virtually contiguous memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
