Date: Tue, 20 Mar 2001 17:33:49 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: 3rd version of R/W mmap_sem patch available
Message-ID: <20010320173349.A4839@fred.local>
References: <3AB77311.77EB7D60@uow.edu.au> <Pine.LNX.4.31.0103200801480.1503-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.31.0103200801480.1503-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Tue, Mar 20, 2001 at 05:08:36PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <andrewm@uow.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 20, 2001 at 05:08:36PM +0100, Linus Torvalds wrote:
> > General comment: an expensive part of a pagefault
> > is zeroing the new page.  It'd be nice if we could
> > drop the page_table_lock while doing the clear_user_page()
> > and, if possible, copy_user_page() functions.  Very nice.
> 
> I don't think it's worth it. We should have basically zero contention on
> this lock now, and adding complexity to try to release it sounds like a
> bad idea when the only way to make contention on it is (a) kswapd (only
> when paging stuff out) and (b) multiple threads (only when taking
> concurrent page faults).

Isn't (b) a rather common case in multi threaded applications ? 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
