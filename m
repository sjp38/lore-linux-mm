Date: Fri, 15 Oct 2004 18:09:27 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] use find_trylock_page in free_swap_and_cache instead of hand coding
Message-ID: <20041015210927.GE4937@logos.cnet>
References: <20041015183556.GB4937@logos.cnet> <Pine.LNX.4.44.0410152248460.7849-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410152248460.7849-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 15, 2004 at 10:54:43PM +0100, Hugh Dickins wrote:
> On Fri, 15 Oct 2004, Marcelo Tosatti wrote:
> > On Fri, Oct 15, 2004 at 02:20:08PM +0100, Hugh Dickins wrote:
> > > But please extend your patch to mm/swap_state.c, where you can get rid
> > > of the two radix_tree_lookups by reverting to find_get_page - thanks!
> > 
> > Here it is. Can you please review an Acked-by?
> 
> Looks good, thanks, yes, help yourself to one of these:
> Acked-by: Hugh Dickins <hugh@veritas.com>

OK - Andrew can you please apply it to -mm.

> > That raises a question in my mind: The swapper space statistics
> > are not protected by anything.
> > 
> > Two processors can write to it at the same time - I can imagine
> > we lose a increment (two CPUs increasing at the same time), but
> > what else can happen to the statistics due to the lack of locking?
> 
> That's right.  It just doesn't matter at all: much better to lose
> the occasional increment than weigh it down with locking or atomicity.

Agreed.

> When was the last time you or anyone took any interest in those
> numbers?  From time to time I think of just ripping them  out.

I was thinking the same when reading the code.

The thing is, there might be users still - we probably want to keep
compatibility (heck, I dont know compatibility to what, but lets 
imagine there is some application out there who uses it).

I think we can make it optional on CONFIG_EMBEDDED - if its 
set, make the INC_CACHE_ #defines NULL. What you think of that?

Then remove later on v2.7.

Thats a conservative approach - we could just rip off it completly. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
