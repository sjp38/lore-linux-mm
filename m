Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id j95FxJTZ192790
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 15:59:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95FxJvk181536
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 17:59:19 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j95FxJVo025336
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 17:59:19 +0200
Date: Wed, 5 Oct 2005 17:58:23 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005155823.GA10119@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com> <1128442502.20208.6.camel@localhost> <20051005063909.GA9699@osiris.boeblingen.de.ibm.com> <1128527554.26009.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128527554.26009.2.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > to be traversed during a lookup: the page tables.  Granted, the TLB will
> > > provide some caching, but a lookup on ia64 can potentially be much more
> > > expensive than the two cacheline misses that sparsemem extreme might
> > > have.
> > Sure, just that on s390 we have a 1:1 mapping anyway. So these lookups would
> > be more or less for free for us (compared to what we have now).
> Is the 1:1 mapping done with pagetables?  If so, it is not free.

Sure, it's done with pagetables. What I meant: we have the 1:1 mapping already
today. So adding anything to the vmalloc area won't make it more expensive.

> > Actually my concern is that whenever the address space that is covered with
> > SPARSEMEM_EXTREME is not sufficient just another layer of indirection needs
> > to be added.
> Do you have any performance numbers to back up your concerns, or is it
> more about the code complexity?

No, my concern is actually that the s390 archticture actually will come up
with some sort of memory that's present in the physical address space where
the most significant bit of the addresses will be turned _on_. That means we
would need to support the whole 64 bit physical address space...
Considering this, this would be good for at least one if not two additional
indirection layers, which would make the code too complex, IMHO.
That's why I think the vmem_map approach would be easiest to implement this :)

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
