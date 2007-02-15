Date: Thu, 15 Feb 2007 07:19:49 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] Logic to move mlocked pages
In-Reply-To: <20070214213321.0633d570.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702150717020.10403@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
 <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
 <20070214213321.0633d570.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Andrew Morton wrote:

> >  			list_add_tail(&page->lru, pagelist);
> > +		} else
> > +		if (PageMlocked(page)) {
> > +			ret = 0;
> > +			get_page(page);
> > +			ClearPageMlocked(page);
> > +			list_add_tail(&page->lru, pagelist);
> > +			__dec_zone_state(zone, NR_MLOCK);
> >  		}
> >  		spin_unlock_irq(&zone->lru_lock);
> 
> argh.  Please change your scripts to use `diff -p'.

Ok. That machine did not have it. Sigh.
 
> Why does whatever-funtion-this-is do the get_page() there?  Looks odd.

The refcount has to be elevated the same way as for regular LRU pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
