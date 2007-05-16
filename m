Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GNUsF5002298
	for <linux-mm@kvack.org>; Wed, 16 May 2007 19:30:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GNUsEu516854
	for <linux-mm@kvack.org>; Wed, 16 May 2007 19:30:54 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GNUs1c021384
	for <linux-mm@kvack.org>; Wed, 16 May 2007 19:30:54 -0400
Date: Wed, 16 May 2007 16:30:53 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 1/3] hugetlb: remove unnecessary nid initialization
Message-ID: <20070516233053.GN20535@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

nid is initialized to numa_node_id() but will either be overwritten in
the loop or not used in the conditional. So remove the initialization.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eb7180d..abcd9a9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -66,7 +66,7 @@ static void enqueue_huge_page(struct page *page)
 static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 				unsigned long address)
 {
-	int nid = numa_node_id();
+	int nid;
 	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address);
 	struct zone **z;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
