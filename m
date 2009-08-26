Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 616C26B0087
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:56:12 -0400 (EDT)
Date: Wed, 26 Aug 2009 11:12:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
Message-ID: <20090826101202.GE10955@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192902.10317.94512.sendpatchset@localhost.localdomain> <20090825133516.GE21335@csn.ul.ie> <1251233380.16229.3.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251233380.16229.3.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 04:49:40PM -0400, Lee Schermerhorn wrote:
> On Tue, 2009-08-25 at 14:35 +0100, Mel Gorman wrote:
> > On Mon, Aug 24, 2009 at 03:29:02PM -0400, Lee Schermerhorn wrote:
> > > <SNIP>
> > >
> > > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h
> > > ===================================================================
> > > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/node.h	2009-08-24 12:12:44.000000000 -0400
> > > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h	2009-08-24 12:12:56.000000000 -0400
> > > @@ -21,9 +21,12 @@
> > >  
> > >  #include <linux/sysdev.h>
> > >  #include <linux/cpumask.h>
> > > +#include <linux/hugetlb.h>
> > >  
> > 
> > Is this header inclusion necessary? It does not appear to be required by
> > the structure modification (which is iffy in itself as discussed in the
> > earlier mail) and it breaks build on x86-64.
> 
> Hi, Mel:
> 
> I recall that it is necessary to build.  You can try w/o it.
> 

I did, it appeared to work but I didn't dig deep as to why.

> > 
> >  CC      arch/x86/kernel/setup_percpu.o
> > In file included from include/linux/pagemap.h:10,
> >                  from include/linux/mempolicy.h:62,
> >                  from include/linux/hugetlb.h:8,
> >                  from include/linux/node.h:24,
> >                  from include/linux/cpu.h:23,
> >                  from /usr/local/autobench/var/tmp/build/arch/x86/include/asm/cpu.h:5,
> >                  from arch/x86/kernel/setup_percpu.c:19:
> > include/linux/highmem.h:53: error: static declaration of kmap follows non-static declaration
> > /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:60: error: previous declaration of kmap was here
> > include/linux/highmem.h:59: error: static declaration of kunmap follows non-static declaration
> > /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:61: error: previous declaration of kunmap was here
> > include/linux/highmem.h:63: error: static declaration of kmap_atomic follows non-static declaration
> > /usr/local/autobench/var/tmp/build/arch/x86/include/asm/highmem.h:63: error: previous declaration of kmap_atomic was here
> > make[2]: *** [arch/x86/kernel/setup_percpu.o] Error 1
> > make[1]: *** [arch/x86/kernel] Error 2
> 
> I saw this.  I've been testing on x86_64.  I *thought* that it only
> started showing up in a recent mmotm from changes in the linux-next
> patch--e.g., a failure to set ARCH_HAS_KMAP or to handle appropriately
> !ARCH_HAS_KMAP in highmem.h  But maybe that was coincidental with my
> adding the include.
> 

Maybe we were looking at different mmotm's

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
