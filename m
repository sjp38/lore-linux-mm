Date: Tue, 30 Mar 2004 00:54:35 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040329225435.GN3808@dualathlon.random>
References: <20040329124027.36335d93.akpm@osdl.org> <Pine.LNX.4.44.0403292312170.19944-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0403292312170.19944-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2004 at 11:24:58PM +0100, Hugh Dickins wrote:
> On Mon, 29 Mar 2004, Andrew Morton wrote:
> > 
> > hmm, yes, we have pages which satisfy PageSwapCache(), but which are not
> > actually in swapcache.
> > 
> > How about we use the normal pagecache APIs for this?
> > 
> > +	add_to_page_cache(page, &swapper_space, entry.val, GFP_NOIO);
> >...  
> > +	remove_from_page_cache(page);
> 
> Much nicer, and it'll probably appear to work: but (also untested)
> I bet you'll need an additional page_cache_release(page) - damn,

I'll add the page_cache_release before testing ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
