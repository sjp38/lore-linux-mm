Date: Tue, 18 Sep 2007 12:41:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon() function
In-Reply-To: <1190127886.5035.10.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709181241110.3714@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205425.6536.69946.sendpatchset@localhost>
 <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
 <1190127886.5035.10.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Lee Schermerhorn wrote:

> > > +static inline int page_anon(struct page *page)
> > > +{
> > > +	struct address_space *mapping;
> > > +
> > > +	if (PageAnon(page) || PageSwapCache(page))
> > > +		return 1;
> > > +	mapping = page_mapping(page);
> > > +	if (!mapping || !mapping->a_ops)
> > > +		return 0;
> > > +	if (mapping->a_ops == &shmem_aops)
> > > +		return 1;
> > > +	/* Should ramfs pages go onto an mlocked list instead? */
> > > +	if ((unlikely(mapping->a_ops->writepage == NULL && PageDirty(page))))
> > > +		return 1;
> > > +
> > > +	/* The page is page cache backed by a normal filesystem. */
> > > +	return 0;
> > > +}
> Other ideas?

page_memory_backed()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
