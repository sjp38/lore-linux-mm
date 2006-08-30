Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7U7TXIA025570
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 03:29:33 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7U7TXYS341682
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:29:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7U7TXk9008070
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:29:33 -0600
Date: Wed, 30 Aug 2006 00:29:48 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: libnuma interleaving oddness
Message-ID: <20060830072948.GE5195@us.ibm.com>
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com> <20060830002110.GZ5195@us.ibm.com> <200608300919.13125.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200608300919.13125.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 30.08.2006 [09:19:13 +0200], Andi Kleen wrote:
> mous pages.
> > 
> > The order is (with necessary params filled in):
> > 
> > p = mmap( , newsize, RW, PRIVATE, unlinked_hugetlbfs_heap_fd, );
> > 
> > numa_interleave_memory(p, newsize);
> > 
> > mlock(p, newsize); /* causes all the hugepages to be faulted in */
> > 
> > munlock(p,newsize);
> > 
> > From what I gathered from the numa manpages, the interleave policy
> > should take effect on the mlock, as that is "fault-time" in this
> > context. We're forcing the fault, that is.
> 
> mlock shouldn't be needed at all here. the new hugetlbfs is supposed
> to reserve at mmap time and numa_interleave_memory() sets a VMA policy
> which will should do the right thing no matter when the fault occurs.

Ok.

> Hmm, maybe mlock() policy() is broken.

I took out the mlock() call, and I get the same results, FWIW.

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
