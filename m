Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5IIG8jE015653
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 14:16:08 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5IIKcOH203698
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 12:20:41 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5IIKZN0004047
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 12:20:35 -0600
Date: Mon, 18 Jun 2007 11:20:01 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 1/3] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070618182001.GE10714@us.ibm.com>
References: <20070618173428.GB10714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618173428.GB10714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 18.06.2007 [10:34:28 -0700], Nishanth Aravamudan wrote:
> Anton found a problem with the hugetlb pool allocation when some nodes
> have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
> worked on versions that tried to fix it, but none were accepted.
> Christoph has created a set of patches which allow for GFP_THISNODE
> allocations to fail if the node has no memory and for exporting a
> node_memory_map indicating which nodes have memory. Since mempolicy.c
> already has a number of functions which support interleaving, create a
> mempolicy when we invoke alloc_fresh_huge_page() that specifies
> interleaving across all the nodes in node_memory_map, rather than custom
> interleaving code in hugetlb.c.  This requires adding some dummy
> functions, and some declarations, in mempolicy.h to compile with NUMA or
> !NUMA.

Sigh, in case it wasn't clear from the preceding dicussions, these
patches depend on Christoph's memoryless node fixes.

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
