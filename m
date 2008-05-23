Date: Fri, 23 May 2008 07:41:33 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523054133.GO13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430204841.GD6903@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 01:48:41PM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:19 +1000], npiggin@suse.de wrote:
> > Add an hugepagesz=... option similar to IA64, PPC etc. to x86-64.
> > 
> > This finally allows to select GB pages for hugetlbfs in x86 now
> > that all the infrastructure is in place.
> 
> Another more basic question ... how do we plan on making these hugepages
> available to applications. Obviously, an administrator can mount
> hugetlbfs with pagesize=1G or whatever and then users (with appropriate
> permissions) can mmap() files created therein. But what about
> SHM_HUGETLB? It uses a private internal mount of hugetlbfs, which I
> don't believe I saw a patch to add a pagesize= parameter for.
> 
> So SHM_HUGETLB will (for now) always get the "default" hugepagesize,
> right, which should be the same as the legacy size? Given that an
> architecture may support several hugepage sizes, I have't been able to
> come up with a good way to extend shmget() to specify the preferred
> hugepagesize when SHM_HUGETLB is specified. I think for libhugetlbfs
> purposes, we will probably add another environment variable to control
> that...

Good question. One thing I like to do in this patch is to make very
minimal as possible API changes even if it means userspace doesn't
get the full functionality in all corner cases like that.

This way we can get the core work in and stabilized, then can take
more time to discuss the user apis.

For that matter, I'm almost inclined to submit the patchset with
only allow one active hstate specified on the command line, and no
changes to any sysctls... just to get the core code merged sooner ;)
however it is very valueable for testing and proof of concept to
allow multiple active hstates to be configured and run, so I think
we have to have that at least in -mm.

We probably have a month or two before the next merge window, so we
have enough time to think about api issues I hope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
