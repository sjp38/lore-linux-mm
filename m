Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AA9C86B0036
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 20:32:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 15 Aug 2013 10:25:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 977B33578051
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 10:32:02 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7F0VjAc66715758
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 10:31:51 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7F0VtlI017965
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 10:31:55 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/4] mm/vmalloc: use wrapper function get_vm_area_size to caculate size of vm area
Date: Thu, 15 Aug 2013 08:31:43 +0800
Message-Id: <1376526703-2081-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use wrapper function get_vm_area_size to calculate size of vm area.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 93d3182..553368c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1553,7 +1553,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	unsigned int nr_pages, array_size, i;
 	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 
-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
+	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
