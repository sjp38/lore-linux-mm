Date: Thu, 5 Aug 2004 22:37:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 1/4: rework alloc_pages
Message-Id: <20040805223725.246b0950.akpm@osdl.org>
In-Reply-To: <41131732.7060606@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
	<20040805221958.49049229.akpm@osdl.org>
	<41131732.7060606@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Andrew Morton wrote:
> > Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > 
> >>Previously the ->protection[] logic was broken. It was difficult to follow
> >> and basically didn't use the asynch reclaim watermarks properly.
> > 
> > 
> > eh?
> > 
> > Broken how?
> > 
> 
> min = (1<<order) + z->protection[alloc_type];
> 
> This value is used both as the condition for waking kswapd, and
> whether or not to enter synch reclaim.
> 
> What should happen is kswapd gets woken at pages_low, and synch
> reclaim is started at pages_min.

Are you aware of this:

void wakeup_kswapd(struct zone *zone)
{
	if (zone->free_pages > zone->pages_low)
		return;

?

> 
> pages_low + protection and pages_min + protection, etc.

Nick, sorry, but I shouldn't have to expend these many braincells
decrypting your work.  Please: much better explanations, more testing
results.  This stuff is fiddly, sensitive and has a habit of blowing up in
our faces weeks later.  We need to be cautious.  The barriers are higher
nowadays.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
