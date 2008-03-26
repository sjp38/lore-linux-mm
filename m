Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QLa3TH006627
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:36:03 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QLbUoH197532
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:37:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QLbThr001449
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:37:30 -0600
Date: Wed, 26 Mar 2008 14:37:53 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 1/2] hugetlb: indicate surplus huge page counts in per-node
	meminfo
Message-ID: <20080326213753.GE14331@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, agl@us.ibm.com, apw@shadowen.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we show the surplus hugetlb pool state in /proc/meminfo, but
not in the per-node meminfo files, even though we track the information
on a per-node basis. Printing it there can help track down dynamic pool
bugs including the one in the follow-on patch.
    
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
This would be nice to have this late in the 2.6.25 cycle, but should not
block the follow-on patch from getting merged.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ecaeedb..548a75d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -719,9 +719,11 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 {
 	return sprintf(buf,
 		"Node %d HugePages_Total: %5u\n"
-		"Node %d HugePages_Free:  %5u\n",
+		"Node %d HugePages_Free:  %5u\n"
+		"Node %d HugePages_Surp:  %5u\n",
 		nid, nr_huge_pages_node[nid],
-		nid, free_huge_pages_node[nid]);
+		nid, free_huge_pages_node[nid],
+		nid, surplus_huge_pages_node[nid]);
 }
 
 #ifdef CONFIG_NUMA

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
