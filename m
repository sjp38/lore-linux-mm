Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4NKdBmf023568
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:39:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4NKdBhn142430
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:39:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4NKdAxc014599
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:39:11 -0400
Date: Fri, 23 May 2008 13:39:08 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523203908.GE23924@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com> <20080523054133.GO13071@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523054133.GO13071@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.05.2008 [07:41:33 +0200], Nick Piggin wrote:
> On Wed, Apr 30, 2008 at 01:48:41PM -0700, Nishanth Aravamudan wrote:
> > On 23.04.2008 [11:53:19 +1000], npiggin@suse.de wrote:
> > > Add an hugepagesz=... option similar to IA64, PPC etc. to x86-64.
> > > 
> > > This finally allows to select GB pages for hugetlbfs in x86 now
> > > that all the infrastructure is in place.
> > 
> > Another more basic question ... how do we plan on making these hugepages
> > available to applications. Obviously, an administrator can mount
> > hugetlbfs with pagesize=1G or whatever and then users (with appropriate
> > permissions) can mmap() files created therein. But what about
> > SHM_HUGETLB? It uses a private internal mount of hugetlbfs, which I
> > don't believe I saw a patch to add a pagesize= parameter for.
> > 
> > So SHM_HUGETLB will (for now) always get the "default" hugepagesize,
> > right, which should be the same as the legacy size? Given that an
> > architecture may support several hugepage sizes, I have't been able to
> > come up with a good way to extend shmget() to specify the preferred
> > hugepagesize when SHM_HUGETLB is specified. I think for libhugetlbfs
> > purposes, we will probably add another environment variable to control
> > that...
> 
> Good question. One thing I like to do in this patch is to make very
> minimal as possible API changes even if it means userspace doesn't get
> the full functionality in all corner cases like that.
> 
> This way we can get the core work in and stabilized, then can take
> more time to discuss the user apis.
> 
> For that matter, I'm almost inclined to submit the patchset with only
> allow one active hstate specified on the command line, and no changes
> to any sysctls... just to get the core code merged sooner ;) however
> it is very valueable for testing and proof of concept to allow
> multiple active hstates to be configured and run, so I think we have
> to have that at least in -mm.
> 
> We probably have a month or two before the next merge window, so we
> have enough time to think about api issues I hope.

I think your plan is sensible, and is certainly how I would approach
adding this support to mainline. That is, all of the core hstate
functionality can probably go upstream rather quickly, as it's
functionally equivalent (and should be easy to verify as such with
libhuge's tests on all supported architectures).

I'm also hoping that once your patches are re-posted and hit -mm, I can
send out my sysfs patch, after updating/testing it, and that could also
go into -mm, which might allow the meminfo and sysctl patches to be
dropped from the series. Depends on your perspective on those, I
suppose, and might also need some coordination with Andrew to make the
series build in the right order (so the sysfs patch can be dropped in,
in place of both of them).

Does that seem reasonable? Also, for -mm coordination, are you going to
pull Jon's patches into your set, then?

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
