Date: Mon, 5 Mar 2007 09:47:16 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [rfc][patch 1/2] mm: rework isolate_lru_page
In-Reply-To: <20070305161655.GC8128@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703050945290.6620@schroedinger.engr.sgi.com>
References: <20070305161655.GC8128@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007, Nick Piggin wrote:

> isolate_lru_page logically belongs to be in vmscan.c than migrate.c.

Good idea.

> + * Isolate one page from the LRU lists. Must be called with an elevated
> + * refcount on the page, which is how it differs from isolate_lru_pages
> + * (which is called without a stable reference).
> + *
> + * lru_lock must not be held, interrupts must be enabled.
> + *
> + * Returns:
> + *  -EBUSY: page not on LRU list
> + *  0: page removed from LRU list and added to the specified list.

The new version of isolate_lru_page no longer adds the page to a list.
Remove that portion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
