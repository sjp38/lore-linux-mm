Date: Thu, 31 Jul 2003 12:12:08 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: Re: Understanding page faults code in mm/memory.c
In-Reply-To: <Pine.LNX.4.53.0307311242370.10913@skynet>
Message-ID: <Pine.GSO.4.51.0307311209220.8932@aria.ncl.cs.columbia.edu>
References: <20030731111502.GA1591@eugeneteo.net> <Pine.LNX.4.53.0307311242370.10913@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Eugene Teo <eugene.teo@eugeneteo.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>
> > [3] in mm/memory.c, in do_wp_page, I am not sure what the
> > portion of code is about:
> >
> > // If old_page bit is not set, set it, and test.
> > if (!TryLockPage(old_page) {
> >
> >     // [QN:] I don't understand what can_share_swap_page() do
> >     // I tried tracing, but i still don't quite get it.
> >     int reuse = can_share_swap_page(old_page);
>
> Basically it'll determine if you are the only user of that swap page. If
> it returns true, it means that you are the last process to break COW on
> that page so just use it. Otherwise it'll fall through and a new page will
> be allocated.

   But when you put a page on to the swap cache will not the rss of the
address spage  decrease. if not then when will the rss value of the
address space change.

 thanks,
Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
