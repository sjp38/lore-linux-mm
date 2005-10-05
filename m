Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j95I5aOI147290
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:05:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95I5avk138026
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 20:05:36 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j95I5Zbl018293
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 20:05:36 +0200
Date: Wed, 5 Oct 2005 20:04:43 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005180443.GC10204@osiris.ibm.com>
References: <20051005063909.GA9699@osiris.boeblingen.de.ibm.com> <1128527554.26009.2.camel@localhost> <20051005155823.GA10119@osiris.ibm.com> <1128528340.26009.8.camel@localhost> <20051005161009.GA10146@osiris.ibm.com> <1128529222.26009.16.camel@localhost> <20051005171230.GA10204@osiris.ibm.com> <1128532809.26009.39.camel@localhost> <20051005174542.GB10204@osiris.ibm.com> <1128535054.26009.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128535054.26009.53.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

> > > > Anything specific you need to know about the memory layout?
> > > How sparse is it?  How few present pages can be there be in a worst-case
> > > physical area?
> > 
> > Worst case that is already currently valid is that you can have 1 MB
> > segments whereever you want in address space.
> ...
> > Even though it's currently not possible to define memory segments above
> > 1TB, this limit is likely to go away.
> 
> Go away, or get moved up?
> 
> ia64 today is designed to work with 50 bits of physical address space,
> and 30 bit sections.  That's exactly the same scale that you're talking
> about with 1MB sections and 1TB of physical space.  So, sparsemem
> extreme should be perfectly fine for that case (that's explicitly what
> it was designed for).
> 
> How much bigger than 1TB will it go?

As already mentioned, we will have physical memory with the MSB set. Afaik
the hardware uses this bit to distinguish between different types of memory.
So we are going to have the full 64 bit address space.

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
