Date: Sat, 28 Aug 2004 09:35:30 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Avoid unecessary zone spinlocking on refill_inactive_zone()
Message-ID: <20040828123530.GA2033@logos.cnet>
References: <20040828005550.GC4482@logos.cnet> <413014AF.3050104@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <413014AF.3050104@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28, 2004 at 03:14:23PM +1000, Nick Piggin wrote:
> Marcelo Tosatti wrote:
> 
> >On a side note, the current accounting of inactive/active pages is broken 
> >in refill_inactive_zone (due to pages being freed in __release_pages). 
> >I plan to fix that tomorrow - should be easy as returning the number of 
> >pages
> >freed in __release_pages and take that into account.
> >
> 
> Hi,
> I don't think this is a problem: release_pages should do del_page_from_lru,
> which would take care of accounting, wouldn't it?
> 
> Maybe I'm not looking in the right place.

Oh no, you are right, del_page_from_lru() will do the accounting.

Sorry for the noise.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
