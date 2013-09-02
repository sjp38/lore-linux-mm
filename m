Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BC5AB6B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 08:35:54 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 2 Sep 2013 17:59:42 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9DA0B394004E
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 18:05:38 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82CbYjc45809790
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 18:07:34 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r82CZmv6012830
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 18:05:49 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/vmalloc: don't set area->caller twice
Date: Mon,  2 Sep 2013 20:35:43 +0800
Message-Id: <1378125345-13228-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The caller address has already been set in set_vmalloc_vm(), there's no need 
to set it again in __vmalloc_area_node.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1074543..d78d117 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1566,7 +1566,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
                pages = kmalloc_node(array_size, nested_gfp, node);
        }
        area->pages = pages;
-       area->caller = caller;
        if (!area->pages) {
                remove_vm_area(area->addr);
                kfree(area);
--
1.8.1.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
