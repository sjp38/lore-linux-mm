Date: Thu, 27 Nov 2008 11:38:06 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] radix-tree: document wrap-around issue of
 radix_tree_next_hole()
In-Reply-To: <20081123105155.GA14524@localhost>
Message-ID: <alpine.LNX.1.10.0811271137240.19853@jikos.suse.cz>
References: <20081123105155.GA14524@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trivial Patch Monkey <trivial@kernel.org>, Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Nov 2008, Wu Fengguang wrote:

> And some 80-line cleanups.
> 
> Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
> ---
>  lib/radix-tree.c |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> --- linux-2.6.orig/lib/radix-tree.c
> +++ linux-2.6/lib/radix-tree.c
> @@ -640,13 +640,14 @@ EXPORT_SYMBOL(radix_tree_tag_get);
>   *
>   *	Returns: the index of the hole if found, otherwise returns an index
>   *	outside of the set specified (in which case 'return - index >= max_scan'
> - *	will be true).
> + *	will be true). In rare cases of index wrap-around, 0 will be returned.
>   *
>   *	radix_tree_next_hole may be called under rcu_read_lock. However, like
> - *	radix_tree_gang_lookup, this will not atomically search a snapshot of the
> - *	tree at a single point in time. For example, if a hole is created at index
> - *	5, then subsequently a hole is created at index 10, radix_tree_next_hole
> - *	covering both indexes may return 10 if called under rcu_read_lock.
> + *	radix_tree_gang_lookup, this will not atomically search a snapshot of
> + *	the tree at a single point in time. For example, if a hole is created
> + *	at index 5, then subsequently a hole is created at index 10,
> + *	radix_tree_next_hole covering both indexes may return 10 if called
> + *	under rcu_read_lock.
>   */
>  unsigned long radix_tree_next_hole(struct radix_tree_root *root,
>  				unsigned long index, unsigned long max_scan)
> 

I don't see this applied in any of the publically visible trees, so I have 
taken this into -trivial. Please let me know if it has been through any 
other channel already.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
