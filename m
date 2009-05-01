Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C477A6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 14:15:02 -0400 (EDT)
Date: Fri, 1 May 2009 20:14:49 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V2
Message-ID: <20090501181449.GA8912@cmpxchg.org>
References: <20090428090129.17081.782.sendpatchset@rx1.opensource.se> <aec7e5c30904302026q42ecbd57m6e88c937bbd262bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <aec7e5c30904302026q42ecbd57m6e88c937bbd262bb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-media@vger.kernel.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 12:26:38PM +0900, Magnus Damm wrote:
> On Tue, Apr 28, 2009 at 6:01 PM, Magnus Damm <magnus.damm@gmail.com> wrote:
> > This is V2 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.
> 
> I guess the V4L2 specific bits are pretty simple.
> 
> As for the minor mm modifications below,
> 
> > --- 0001/mm/memory.c
> > +++ work/mm/memory.c    2009-04-28 14:56:43.000000000 +0900
> > @@ -3009,7 +3009,6 @@ int in_gate_area_no_task(unsigned long a
> >
> >  #endif /* __HAVE_ARCH_GATE_AREA */
> >
> > -#ifdef CONFIG_HAVE_IOREMAP_PROT
> >  int follow_phys(struct vm_area_struct *vma,
> >                unsigned long address, unsigned int flags,
> >                unsigned long *prot, resource_size_t *phys)
> 
> Is it ok with the memory management guys to always build follow_phys()?

AFAICS, pte_pgprot is only defined on three architectures that have
the config symbol above set.  It shouldn't compile on the others.

I have a patch that factors out follow_pte and builds follow_pfn and
follow_phys on top of that.  I can send it monday, no access to it
from here right now.

Then we can keep follow_phys private to this configuration.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
