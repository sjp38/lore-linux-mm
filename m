Date: Mon, 7 Aug 2006 11:11:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/2] mm: speculative get_page
In-Reply-To: <20060726063905.GA32107@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0608071058510.9318@blonde.wat.veritas.com>
References: <20060726063905.GA32107@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A basic question I need to understand before going further...

On Wed, 26 Jul 2006, Nick Piggin wrote:
> + *
> + * This forms the core of the lockless pagecache locking protocol, where
> + * the lookup-side (eg. find_get_page) has the following pattern:
> + * 1. find page in radix tree
> + * 2. conditionally increment refcount
> + * 3. wait for PageNoNewRefs

(Better say
         wait while PageNoNewRefs
)

> + * 4. check the page is still in pagecache
> + *
> + * Remove-side (that cares about _count, eg. reclaim) has the following:
> + * A. SetPageNoNewRefs
> + * B. check refcount is correct
> + * C. remove page
> + * D. ClearPageNoNewRefs

Yes, I understand why remove_mapping and migrate_page_move_mapping
(on page) do the PageNoNewRefs business; but why do add_to_page_cache,
__add_to_swap_cache and migrate_page_move_mapping (on newpage) do it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
