Subject: Re: [patch 4/9] mm: lockless pagecache lookups
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060922172120.22370.4933.sendpatchset@linux.site>
References: <20060922172042.22370.62513.sendpatchset@linux.site>
	 <20060922172120.22370.4933.sendpatchset@linux.site>
Content-Type: text/plain
Date: Fri, 22 Sep 2006 16:01:11 -0400
Message-Id: <1158955271.5584.58.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-09-22 at 21:22 +0200, Nick Piggin wrote:
> Combine page_cache_get_speculative with lockless radix tree lookups to
> introduce lockless page cache lookups (ie. no mapping->tree_lock on
> the read-side).
> 
> The only atomicity changes this introduces is that the gang pagecache
> lookup functions now behave as if they are implemented with multiple
> find_get_page calls, rather than operating on a snapshot of the pages.
> In practice, this atomicity guarantee is not used anyway, and it is
> difficult to see how it could be. Gang pagecache lookups are designed
> to replace individual lookups, so these semantics are natural.
> 

vvv - stale comment?
> Swapcache can no longer use find_get_page, because it has a different
> method of encoding swapcache position into the page. Introduce a new
> find_get_swap_page for it.

^^^ 
> 

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
