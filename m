Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76GdXgA002002
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:39:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76GdWBl131726
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:39:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76GdWkr012042
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:39:32 -0400
Date: Mon, 6 Aug 2007 09:39:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 0/5] hugetlb NUMA improvements
Message-ID: <20070806163931.GM15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806163254.GJ15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [09:32:54 -0700], Nishanth Aravamudan wrote:
> The following stack of 5 patches give hugetlbfs improved NUMA support.
> 
> 1/5: Fix hugetlb pool allocation with empty nodes V9
> 	The most important of the patches, fix hugetlb pool allocation
> 	in the presence of memoryless nodes.
> 
> 2/5: hugetlb: numafy several functions
> 3/5: hugetlb: add per-node nr_hugepages sysfs attribute
> 	Together, add a per-node sysfs attribute for the number of
> 	hugepages allocated on the node.  This gives system
> 	administrators more fine-grained control of the global pool's
> 	distribution.
> 
> 4/5: hugetlb: fix cpuset-constrained pool resizing
> 	fix cpuset-constrained resizing in the presence of the previous
> 	3 patches.
> 
> 5/5: hugetlb: interleave dequeueing of huge pages
> 	add interleaving to the dequeue path for hugetlb, so that
> 	hugepages are removed from all available nodes when the pool
> 	shrinks. Given the sysfs attribute the current node-at-a-time
> 	dequeueing is still possible.

I forgot to mention that this stack depends on Christoph's set of
memoryless nodes patches. In particular the node_states nodemask array
and the fix for GFP_THISNODE allocations.

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
