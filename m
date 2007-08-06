Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76GWwP8002849
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:32:58 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GWwOi207000
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:32:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GWvM5024494
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:32:58 -0600
Date: Mon, 6 Aug 2007 09:32:54 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 0/5] hugetlb NUMA improvements
Message-ID: <20070806163254.GJ15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

The following stack of 5 patches give hugetlbfs improved NUMA support.

1/5: Fix hugetlb pool allocation with empty nodes V9
	The most important of the patches, fix hugetlb pool allocation
	in the presence of memoryless nodes.

2/5: hugetlb: numafy several functions
3/5: hugetlb: add per-node nr_hugepages sysfs attribute
	Together, add a per-node sysfs attribute for the number of
	hugepages allocated on the node.  This gives system
	administrators more fine-grained control of the global pool's
	distribution.

4/5: hugetlb: fix cpuset-constrained pool resizing
	fix cpuset-constrained resizing in the presence of the previous
	3 patches.

5/5: hugetlb: interleave dequeueing of huge pages
	add interleaving to the dequeue path for hugetlb, so that
	hugepages are removed from all available nodes when the pool
	shrinks. Given the sysfs attribute the current node-at-a-time
	dequeueing is still possible.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
