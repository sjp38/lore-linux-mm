Date: Tue, 20 Mar 2001 09:13:42 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <20010320173349.A4839@fred.local>
Message-ID: <Pine.LNX.4.31.0103200911490.1605-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Andrew Morton <andrewm@uow.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 20 Mar 2001, Andi Kleen wrote:
> >
> > I don't think it's worth it. We should have basically zero contention on
> > this lock now, and adding complexity to try to release it sounds like a
> > bad idea when the only way to make contention on it is (a) kswapd (only
> > when paging stuff out) and (b) multiple threads (only when taking
> > concurrent page faults).
>
> Isn't (b) a rather common case in multi threaded applications ?

Not if you're performance-sensitive, I bet. If you take so many pagefaults
that the page_table_lock ends up being a problem, you have _more_ problems
than that.

We'll see. I will certainly re-consider if it ends up being shown to be a
real problem. spinlock contention tends to be very easy to see on kernel
profiles, especially the way they're done on Linux/x86 (inline - so you
see evrey contention place separately).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
