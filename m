Date: Tue, 1 Jul 2003 12:08:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.5.73-mm2
In-Reply-To: <20030701105134.GE26348@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0307011202550.1217-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jul 2003, William Lee Irwin III wrote:
> On Tue, Jul 01, 2003 at 11:46:34AM +0100, Hugh Dickins wrote:
> > If you pursued it, wouldn't your patch also need to change
> > nr_free_buffer_pages() to do what you think it does, count
> > the free lowmem pages?  It, and nr_free_pagecache_pages(),
> > and nr_free_zone_pages(), are horribly badly named.  They
> > count present_pages-pages_high, they don't count free pages:
> > okay for initialization estimates, useless for anything dynamic.
> 
> Well, I was mostly looking for getting handed back 0 when lowmem is
> empty; I actually did realize they didn't give entirely accurate counts
> of free lowmem pages.

I'm not pleading for complete accuracy, but nr_free_buffer_pages()
will never hand back 0 (if your system managed to boot).
It's a static count of present_pages (adjusted), not of
free pages.  Or am I misreading nr_free_zone_pages()?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
