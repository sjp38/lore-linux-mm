Date: Thu, 7 Dec 2006 19:17:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
Message-Id: <20061207191731.066632fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061207100659.GA9059@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
	<20061206181317.GA10042@osiris.ibm.com>
	<Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
	<20061207100659.GA9059@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006 11:06:59 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> On Wed, Dec 06, 2006 at 10:17:04AM -0800, Christoph Lameter wrote:
> > On Wed, 6 Dec 2006, Heiko Carstens wrote:
> > 
> > > > +	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
> > > > +	vmap_end = vmap_start + PAGES_PER_SECTION * sizeof(struct page);
> > > > +
> > > > +	for (vmap = vmap_start;
> > > > +	     vmap != vmap_end;
> > > > +	     vmap += PAGE_SIZE)
> > > > +	{
> > >
> > > Hmm.. maybe I'm just too tired. But why does this work? Why is vmap_start
> > > PAGE_SIZE aligned and why is vmap_end PAGE_SIZE aligned too?
> > 
> > vmap_start is page aligned because pfn_to_page returns a page address.
> > Pages are page aligned.
> 
> I must be dreaming... I always though pfn_to_page return the address to
> the beloging 'struct page'... and indeed it does. So there is nothing
> that guarantees that this is page aligned.
> 
I assumes that page struct of sparsemem's each section's first page is always
aligned to PAGE_SIZE. so this is safe.

ia64 example:
sizeof(struct page) = 56 bytes
PAGES_PER_SECTION = 65536
PAGE_SIZE = 16384

56 * 65536 % 16384 = 0.

- Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
