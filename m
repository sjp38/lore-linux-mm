Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.12.10/8.12.10) with ESMTP id j956e7d7179720
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 06:40:07 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j956e7vk162946
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 08:40:07 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j956e7HD031403
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 08:40:07 +0200
Date: Wed, 5 Oct 2005 08:39:09 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com> <1128442502.20208.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128442502.20208.6.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > I'm just wondering why there is all this indirection stuff here and why not
> > have one contiguous aray of struct pages (residing in the vmalloc area) that
> > deals with whatever size of memory an architecture wants to support.
> This is exactly what ia64 does today.  Programatically, it does remove a
> layer of indirection.  However, there are some data structures that have
> to be traversed during a lookup: the page tables.  Granted, the TLB will
> provide some caching, but a lookup on ia64 can potentially be much more
> expensive than the two cacheline misses that sparsemem extreme might
> have.

Sure, just that on s390 we have a 1:1 mapping anyway. So these lookups would
be more or less for free for us (compared to what we have now).

> In the end no one has ever produced any compelling performance reason to
> use a vmem_map (as ia64 calls it).  In addition, sparsemem doesn't cause
> any known performance regressions, either.

As far as I understand the memory hotplug patches they won't work without
SPARSEMEM support. So the ia64 approach with a vmem_map will not work here,
right?

Actually my concern is that whenever the address space that is covered with
SPARSEMEM_EXTREME is not sufficient just another layer of indirection needs
to be added.

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
