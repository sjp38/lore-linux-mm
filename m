Date: Thu, 7 Dec 2006 09:20:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
Message-Id: <20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
	<20061206181317.GA10042@osiris.ibm.com>
	<Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: heiko.carstens@de.ibm.com, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Dec 2006 10:17:04 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 6 Dec 2006, Heiko Carstens wrote:
> 
> > > +	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
> > > +	vmap_end = vmap_start + PAGES_PER_SECTION * sizeof(struct page);
> > > +
> > > +	for (vmap = vmap_start;
> > > +	     vmap != vmap_end;
> > > +	     vmap += PAGE_SIZE)
> > > +	{
> > 
> > Hmm.. maybe I'm just too tired. But why does this work? Why is vmap_start
> > PAGE_SIZE aligned and why is vmap_end PAGE_SIZE aligned too?
> 
> vmap_start is page aligned because pfn_to_page returns a page address. 
> Pages are page aligned. 
> 
> vmap_end is only page aligned if sizeof(struct page) and PAGES_PER_SECTION 
> play nicely together. Which may not be the case on 64 bit platforms where 
> sizeof(struct page) is not a power of two.
> 
Now, (for example ia64) sizeof(struct page)=56 and PAGES_PER_SECTION=65536,
Then, sizeof(struct page) * PAGES_PER_SECTION is page-aligned.(16kbytes pages.)

This trick is very useful. But yes, if PAGES_PER_SECTION goes down to very small size
this is not true. I hope every arch keeps this assumption.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
