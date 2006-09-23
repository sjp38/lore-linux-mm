Date: Sat, 23 Sep 2006 04:35:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/9] mm: lockless pagecache lookups
Message-ID: <20060923023536.GD23015@wotan.suse.de>
References: <20060922172042.22370.62513.sendpatchset@linux.site> <20060922172120.22370.4933.sendpatchset@linux.site> <1158955271.5584.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1158955271.5584.58.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 22, 2006 at 04:01:11PM -0400, Lee Schermerhorn wrote:
> On Fri, 2006-09-22 at 21:22 +0200, Nick Piggin wrote:
> > Combine page_cache_get_speculative with lockless radix tree lookups to
> > introduce lockless page cache lookups (ie. no mapping->tree_lock on
> > the read-side).
> > 
> > The only atomicity changes this introduces is that the gang pagecache
> > lookup functions now behave as if they are implemented with multiple
> > find_get_page calls, rather than operating on a snapshot of the pages.
> > In practice, this atomicity guarantee is not used anyway, and it is
> > difficult to see how it could be. Gang pagecache lookups are designed
> > to replace individual lookups, so these semantics are natural.
> > 
> 
> vvv - stale comment?

Yep, thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
