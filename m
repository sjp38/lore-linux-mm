Date: Wed, 31 Mar 2004 19:28:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040331172851.GJ2143@dualathlon.random>
References: <20040331150718.GC2143@dualathlon.random> <Pine.LNX.4.44.0403311735560.27163-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0403311735560.27163-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2004 at 05:45:31PM +0100, Hugh Dickins wrote:
> On Wed, 31 Mar 2004, Andrea Arcangeli wrote:
> > 
> > So I rewritten the fix this way:
> > 
> > +	ret = add_to_swap_cache(page, entry);
> 
> I think you'll find that gets into trouble on the header page,
> entry 0, which pmdisk/swsusp does access through this interface,
> but swapping does not: I'd expect its swap_duplicate to fail.

I didn't know they have to modify the header page.

> I've put off dealing with this, wasn't a priority for me to
> decide what to do with it.  You might experiment with setting
> p->swap_map[0] = 1 instead of SWAP_MAP_BAD in sys_swapon, but
> offhand I'm unsure whether that's enough e.g. would the totals
> come out right, would swapoff complete?
> 
> Just an idea, not something to finalize.

if they run into trouble I'll return to the pagecache API adding the
GFP_KERNEL and check for oom failure.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
