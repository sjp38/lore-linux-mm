Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A2676B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 08:35:32 -0400 (EDT)
Received: by pwi6 with SMTP id 6so129484pwi.14
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 05:35:31 -0700 (PDT)
Date: Fri, 4 Jun 2010 21:35:24 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: 4-Kb page-size for kernel in ARM-Cortex
Message-ID: <20100604123524.GB1879@barrios-desktop>
References: <AANLkTimHrbAq1Q3Iu3wYGLDdeidYGgy2txaYkYhg5a_x@mail.gmail.com>
 <20100604123234.GA1879@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100604123234.GA1879@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Uma shankar <shankar.vk@gmail.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

My bad. wrong address. correct it. 

On Fri, Jun 04, 2010 at 09:32:34PM +0900, Minchan Kim wrote:
> On Thu, Jun 03, 2010 at 08:13:35PM +0530, Uma shankar wrote:
> > Hi,
> > 
> >           It is my understanding that  in ARM, the MMU setting for
> > kernel VA  range ( 0xc0000000 onwards )
> > is set up using the section-sized mapping ( 1 Mb in size ) ,  as this
> > range maps to a  contiguous physical address range.
> > 
> > I am trying out a memory-checking tool on Cortex.    This tool has the
> > requirement that it  needs to be able to set up  PTE for each 4 Kb
> > range of  kernel address.
> > 
> > So,  paging_init ( arch/arm/mm/mmu.c ) is modified for this.
> > 
> > But , with this MMU setting,   the kernel hangs somewhere  after
> > freeing init memory. ( "freeing init mem"  is the last print I see on
> > console. )
> > 
> > For  3-level page-table setting of kernel VA,  do I have to change
> > something else also ?
> 
> It's related to arm architecture. 
> Please, Cced linux-arm-kernel mailing list. 
> Maybe they can solve your problem. 
> 
> P.S) 
> Please send your patch with question, symptom more detail and oops 
> if you can get it. 
> 
> 
> > 
> >               thanks
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
