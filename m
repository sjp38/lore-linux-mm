Date: Mon, 29 Mar 2004 23:24:58 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
    fix
In-Reply-To: <20040329124027.36335d93.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0403292312170.19944-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2004, Andrew Morton wrote:
> 
> hmm, yes, we have pages which satisfy PageSwapCache(), but which are not
> actually in swapcache.
> 
> How about we use the normal pagecache APIs for this?
> 
> +	add_to_page_cache(page, &swapper_space, entry.val, GFP_NOIO);
>...  
> +	remove_from_page_cache(page);

Much nicer, and it'll probably appear to work: but (also untested)
I bet you'll need an additional page_cache_release(page) - damn,
looks like hugetlbfs has found a use for that tiresome asymmetry.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
