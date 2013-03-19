Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 313026B0027
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:58:20 -0400 (EDT)
Date: Tue, 19 Mar 2013 14:58:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm, nobootmem: clean-up of
 free_low_memory_core_early()
Message-ID: <20130319055840.GF8858@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1363670161-9214-2-git-send-email-iamjoonsoo.kim@lge.com>
 <CAE9FiQXypPJbhT4mm-wfbO0G65eNSTRCE0DJoB+bXtNfvg7HbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQXypPJbhT4mm-wfbO0G65eNSTRCE0DJoB+bXtNfvg7HbQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

On Mon, Mar 18, 2013 at 10:51:43PM -0700, Yinghai Lu wrote:
> On Mon, Mar 18, 2013 at 10:16 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > Remove unused argument and make function static,
> > because there is no user outside of nobootmem.c
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> > index cdc3bab..5f0b0e1 100644
> > --- a/include/linux/bootmem.h
> > +++ b/include/linux/bootmem.h
> > @@ -44,7 +44,6 @@ extern unsigned long init_bootmem_node(pg_data_t *pgdat,
> >                                        unsigned long endpfn);
> >  extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
> >
> > -extern unsigned long free_low_memory_core_early(int nodeid);
> >  extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
> >  extern unsigned long free_all_bootmem(void);
> >
> > diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> > index 4711e91..589c673 100644
> > --- a/mm/nobootmem.c
> > +++ b/mm/nobootmem.c
> > @@ -120,7 +120,7 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
> >         return end_pfn - start_pfn;
> >  }
> >
> > -unsigned long __init free_low_memory_core_early(int nodeid)
> > +static unsigned long __init free_low_memory_core_early()
> 
> (void) ?

Yes, fixed version is already sent.
Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
