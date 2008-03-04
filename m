Date: Tue, 4 Mar 2008 16:21:13 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
Message-ID: <20080304162113.601ebb30@cuia.boston.redhat.com>
In-Reply-To: <1204643158.5338.5.camel@localhost>
References: <20080228192908.126720629@redhat.com>
	<20080228192929.031646681@redhat.com>
	<20080304192441.1EA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1204643158.5338.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Mar 2008 10:05:58 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> > IMHO insert "lru" word is better.
> > example,
> > 
> > config NORECLAIM_LRU
> > 	bool "Zone LRU of track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> > 	depends on EXPERIMENTAL && 64BIT
> 
> OK.  But, I'd suggest the 'bool' description be something like:
> 
> config NORECLAIM_LRU
> 	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"

I have added this in the 2.6.25-rc3-mm1 port.

> > 
> > > @@ -356,8 +380,10 @@ void release_pages(struct page **pages, 
> > >  				zone = pagezone;
> > >  				spin_lock_irqsave(&zone->lru_lock, flags);
> > >  			}
> > > -			VM_BUG_ON(!PageLRU(page));
> > > -			__ClearPageLRU(page);
> > > +			is_lru_page = PageLRU(page);
> > > +			VM_BUG_ON(!(is_lru_page));
> > > +			if (is_lru_page)
> > > +				__ClearPageLRU(page);
> > >  			del_page_from_lru(zone, page);
> > >  		}
> > 
> > it seems unnecessary change??
> 
> Hmmm.  Not sure what I was thinking here.  Might be a relic of some
> previous debug instrumentation.  Guess I don't have any problem with
> removing this change.

Removed.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
