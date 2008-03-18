In-reply-to: <1205839896.8514.344.camel@twins> (message from Peter Zijlstra on
	Tue, 18 Mar 2008 12:31:36 +0100)
Subject: Re: [patch 3/8] mm: rotate_reclaimable_page() cleanup
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191944.208962764@szeredi.hu> <1205839896.8514.344.camel@twins>
Message-Id: <E1JbaQk-0005iw-67@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 12:56:34 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > -int rotate_reclaimable_page(struct page *page)
> > +void  rotate_reclaimable_page(struct page *page)
> >  {
> > -	struct pagevec *pvec;
> > -	unsigned long flags;
> > -
> > -	if (PageLocked(page))
> > -		return 1;
> > -	if (PageDirty(page))
> > -		return 1;
> > -	if (PageActive(page))
> > -		return 1;
> > -	if (!PageLRU(page))
> > -		return 1;
> 
> Might be me, but I find the above easier to read than
> 
> > +	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
> > +	    PageLRU(page)) {
> >  

Matter of taste, returning from a middle of a function is generally to
be avoided (unless not).  Anyway, this is just a side effect of the
main cleanup, so I think I'm entitled to choose the style I prefer ;)

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
