Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE2466B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 10:30:04 -0500 (EST)
Date: Wed, 20 Jan 2010 16:30:00 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/1] bootmem: move big allocations behing 4G
Message-ID: <20100120153000.GA13172@cmpxchg.org>
References: <1263855390-32497-1-git-send-email-jslaby@suse.cz> <20100119143355.GB7932@cmpxchg.org> <4B570A15.8040601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B570A15.8040601@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Jiri,

On Wed, Jan 20, 2010 at 02:50:13PM +0100, Jiri Slaby wrote:
> On 01/19/2010 03:33 PM, Johannes Weiner wrote:
> > --- a/include/linux/bootmem.h
> > +++ b/include/linux/bootmem.h
> > @@ -96,20 +96,26 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
> >  				      unsigned long align,
> >  				      unsigned long goal);
> >  
> > +#ifdef MAX_DMA32_PFN
> > +#define BOOTMEM_DEFAULT_GOAL	(__pa(MAX_DMA32_PFN << PAGE_SHIFT))
> > +#else
> > +#define BOOTMEM_DEFAULT_GOAL	MAX_DMA_ADDRESS
> 
> I just noticed this should write:
> #define BOOTMEM_DEFAULT_GOAL   __pa(MAX_DMA_ADDRESS)

Pardon my sloppiness, it's all backwards.  The other case should
be without the __pa(), of course.

I'll send a fixed and tested version later.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
