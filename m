Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id E241916DC4
	for <linux-mm@kvack.org>; Tue, 20 Mar 2001 16:35:51 -0300 (EST)
Date: Tue, 20 Mar 2001 16:33:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <20010320173349.A4839@fred.local>
Message-ID: <Pine.LNX.4.21.0103201632360.1299-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <andrewm@uow.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Mar 2001, Andi Kleen wrote:
> On Tue, Mar 20, 2001 at 05:08:36PM +0100, Linus Torvalds wrote:
> > > General comment: an expensive part of a pagefault
> > > is zeroing the new page.  It'd be nice if we could
> > > drop the page_table_lock while doing the clear_user_page()
> > > and, if possible, copy_user_page() functions.  Very nice.
> > 
> > I don't think it's worth it. We should have basically zero contention on
> > this lock now, and adding complexity to try to release it sounds like a
> > bad idea when the only way to make contention on it is (a) kswapd (only
> > when paging stuff out) and (b) multiple threads (only when taking
> > concurrent page faults).
> 
> Isn't (b) a rather common case in multi threaded applications ? 

Multiple threads pagefaulting on the SAME page of anonymous
memory at the same time ?

I can imagine multiple threads pagefaulting on the same page
of some mmaped database, but on the same page of anonymous
memory ??

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
