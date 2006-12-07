Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB7A799h272394
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 10:07:09 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB7A79Og3018828
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 11:07:09 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB7A78mP006099
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 11:07:09 +0100
Date: Thu, 7 Dec 2006 11:06:59 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on sparsemem
Message-ID: <20061207100659.GA9059@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com> <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com> <20061206181317.GA10042@osiris.ibm.com> <Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 06, 2006 at 10:17:04AM -0800, Christoph Lameter wrote:
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

I must be dreaming... I always though pfn_to_page return the address to
the beloging 'struct page'... and indeed it does. So there is nothing
that guarantees that this is page aligned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
