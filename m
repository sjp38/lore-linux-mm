Date: Thu, 5 Jun 2008 04:01:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080605020106.GA11811@wotan.suse.de>
References: <20080604112939.789444496@amd.local0.net> <20080604113112.777819936@amd.local0.net> <20080604105130.cc4ca4e8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080604105130.cc4ca4e8.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 04, 2008 at 10:51:30AM -0700, Randy Dunlap wrote:
> On Wed, 04 Jun 2008 21:29:53 +1000 npiggin@suse.de wrote:
> 
> > Add an hugepagesz=... option similar to IA64, PPC etc. to x86-64.
> > 
> > This finally allows to select GB pages for hugetlbfs in x86 now
> > that all the infrastructure is in place.
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  Documentation/kernel-parameters.txt |   11 +++++++++--
> >  arch/x86/mm/hugetlbpage.c           |   17 +++++++++++++++++
> >  include/asm-x86/page.h              |    2 ++
> >  3 files changed, 28 insertions(+), 2 deletions(-)
> > 
> > Index: linux-2.6/Documentation/kernel-parameters.txt
> > ===================================================================
> > --- linux-2.6.orig/Documentation/kernel-parameters.txt	2008-06-04 20:47:33.000000000 +1000
> > +++ linux-2.6/Documentation/kernel-parameters.txt	2008-06-04 20:51:24.000000000 +1000
> > @@ -765,8 +765,15 @@ and is between 256 and 4096 characters. 
> >  	hisax=		[HW,ISDN]
> >  			See Documentation/isdn/README.HiSax.
> >  
> > -	hugepages=	[HW,X86-32,IA-64] Maximal number of HugeTLB pages.
> > -	hugepagesz=	[HW,IA-64,PPC] The size of the HugeTLB pages.
> > +	hugepages=	[HW,X86-32,IA-64] HugeTLB pages to allocate at boot.
> > +	hugepagesz=	[HW,IA-64,PPC,X86-64] The size of the HugeTLB pages.
> > +			On x86 this option can be specified multiple times
> 
> Change this x86 to x86-64 like it is both above and below here?
> 
> > +			interleaved with hugepages= to reserve huge pages
> > +			of different sizes. Valid pages sizes on x86-64
> > +			are 2M (when the CPU supports "pse") and 1G (when the
> > +			CPU supports the "pdpe1gb" cpuinfo flag)
> 
> 			                                   flag).


OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
