Date: Sun, 10 Oct 1999 23:53:37 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101450250.16317-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.9910102350240.1556-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Oct 1999, Alexander Viro wrote:

>I still think that just keeping a cyclic list of pages, grabbing from that
>list before taking mmap_sem _if_ we have a chance for blocking
>__get_free_page(), refilling if the list is empty (prior to down()) and
>returning the page into the list if we didn't use it may be the simplest
>way.

I can't understand very well your plan.

We just have a security pool. We just block only when the pool become low.
To refill our just existing pool we have to walk the vmas. That's the
problem in first place.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
