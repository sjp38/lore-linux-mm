Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8PFlgFu005097
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 01:47:42 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PFpEL2257650
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 01:51:14 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PFlOsh006322
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 01:47:24 +1000
Message-ID: <46F92D7E.4030903@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 21:17:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
References: <20070924154638.7565.86666.stgit@kernel> <46F8EF7F.80804@linux.vnet.ibm.com> <1190734249.14295.34.camel@localhost.localdomain>
In-Reply-To: <1190734249.14295.34.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> On Tue, 2007-09-25 at 16:52 +0530, Balbir Singh wrote:
>> Adam Litke wrote:
>>> How it works
>>> ============
>>>
>>> Upon depletion of the hugetlb pool, rather than reporting an error immediately,
>>> first try and allocate the needed huge pages directly from the buddy allocator.
>>> Care must be taken to avoid unbounded growth of the hugetlb pool, so the
>>> hugetlb filesystem quota is used to limit overall pool size.
>>>
>> If I understand hugetlb correctly, there is no accounting of hugepages
>> to the RSS of any process. Since the pool will no longer be static,
>> should we also consider changes to the accounting of hugepages?
> 
> You're right: there is no accounting of huge pages against a process.
> This is also the case for the statically allocated pool so this
> particular issue exists unconditionally.  There are several things
> missing: RSS accounting, counting huge pages towards locked_vm limits,
> etc...  The plan is to address these separately and to fix them all at
> once.
> 

I am interested in the accounting and control of hugepages as an
extension to the current memory controller, we can of-course do this
incrementally.

> In the absence of traditional per-process huge page accounting, the
> kernel has provided an alternate means for restricting a process' access
> to the global hugetlb pool: filesystem permissions and quotas.  It's not
> ideal, but with this patch series, the filesystem permissions and quotas
> remain the effective mechanism for restricting pool growth and
> consumption by processes.
> 

OK, thats what I thought.

Thanks for sharing your plans


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
