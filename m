Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8PBNF8U018113
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 21:23:15 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PBNEpY4833444
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 21:23:14 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PBLie4010190
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 21:21:44 +1000
Message-ID: <46F8EF7F.80804@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 16:52:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
References: <20070924154638.7565.86666.stgit@kernel>
In-Reply-To: <20070924154638.7565.86666.stgit@kernel>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> How it works
> ============
> 
> Upon depletion of the hugetlb pool, rather than reporting an error immediately,
> first try and allocate the needed huge pages directly from the buddy allocator.
> Care must be taken to avoid unbounded growth of the hugetlb pool, so the
> hugetlb filesystem quota is used to limit overall pool size.
> 

If I understand hugetlb correctly, there is no accounting of hugepages
to the RSS of any process. Since the pool will no longer be static,
should we also consider changes to the accounting of hugepages?



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
