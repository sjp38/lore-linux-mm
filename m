Date: Mon, 20 Sep 2004 17:30:11 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Update page-flags.h commentary\
Message-ID: <20040920203010.GH5521@logos.cnet>
References: <20040920193532.GD5521@logos.cnet> <20040920224111.A16285@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040920224111.A16285@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 20, 2004 at 10:41:12PM +0100, Christoph Hellwig wrote:
> On Mon, Sep 20, 2004 at 04:35:32PM -0300, Marcelo Tosatti wrote:
> > Andrew,
> > 
> > There is no such thing as "page->age" (this was true sometime back in the past).
> > 
> > Update page-flags to reflect it.
> > 
> > 
> > --- linux-2.6.9-rc1-mm5/include/linux/page-flags.h.orig	2004-09-20 18:04:51.871654024 -0300
> > +++ linux-2.6.9-rc1-mm5/include/linux/page-flags.h	2004-09-20 18:05:19.647431464 -0300
> > @@ -27,8 +27,8 @@
> >   * For choosing which pages to swap out, inode pages carry a PG_referenced bit,
> >   * which is set any time the system accesses that page through the (mapping,
> >   * index) hash table.  This referenced bit, together with the referenced bit
> > - * in the page tables, is used to manipulate page->age and move the page across
> > - * the active, inactive_dirty and inactive_clean lists.
> > + * in the page tables, is used to move the page across the active, 
> > + * inactive_dirty and inactive_clean lists.
> 
> there's also no inactive_dirty or inactive_clean lists anymore.  Or an
> mapping, index hashtable..

True! Andrew, ignore my patch.

If no one prepares a patch I'll do so later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
