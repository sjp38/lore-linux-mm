Date: Mon, 3 Mar 2008 12:06:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc 05/10] Sparsemem: Vmemmap does not need section bits
In-Reply-To: <20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0803031204170.16049@schroedinger.engr.sgi.com>
References: <20080301040755.268426038@sgi.com> <20080301040814.772847658@sgi.com>
 <20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Mar 2008, KAMEZAWA Hiroyuki wrote:

> I like this change. BTW, could you add following change ?
> (or drop this function in sparsemem-vmemmap.)

I cannot find the function in mm/spase-vmemmap.c
 
> == /inclurde/linux/mm.h==
> #ifndef CONFIG_SPARSEMEM_VMEMMAP
> static inline unsigned long page_to_section(struct page *page)
> {
> 	return pfn_to_section(page_to_pfn(page));
> }
> #else
> static inline unsigned long page_to_section(struct page *page)
> {
>         return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
> }
> #endif

Not sure what this means. If we have CONFIG_SPARSEMEM_VMEMMAP then 
SECTION_MASK == 0. So this would reduce to

#ifndef CONFIG_SPARSEMEM_VMEMMAP
static inline unsigned long page_to_section(struct page *page)
{
       return pfn_to_section(page_to_pfn(page));
}
#else
static inline unsigned long page_to_section(struct page *page)
{
         return 0;
}
#endif

Do you propose to also remove the use of the section bits for regular (non 
vmemmap) sparsemem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
