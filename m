Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva> <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com> <3AB77311.77EB7D60@uow.edu.au> <3AB77443.55B42469@mandrakesoft.com> <3AB777E1.2B233E8A@uow.edu.au>
From: ebiederman@lnxi.com (Eric W. Biederman)
Date: 20 Mar 2001 18:59:27 -0700
In-Reply-To: Andrew Morton's message of "Wed, 21 Mar 2001 02:31:45 +1100"
Message-ID: <m37l1j3mrk.fsf@DLT.linuxnetworx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <andrewm@uow.edu.au> writes:

> Jeff Garzik wrote:
> > 
> > Andrew Morton wrote:
> > > General comment: an expensive part of a pagefault
> > > is zeroing the new page.  It'd be nice if we could
> > > drop the page_table_lock while doing the clear_user_page()
> > > and, if possible, copy_user_page() functions.  Very nice.
> > 
> > People have talked before about creating zero pages in the background,
> > or creating them as a side effect of another operation (don't recall
> > details), so yeah this is definitely an area where some optimizations
> > could be done.  I wouldn't want to do it until 2.5 though...
> 
> Actually, I did this for x86 last weekend :) Initial results are
> disappointing. 
> 
> It creates a special uncachable mapping and sits there
> zeroing pages in a low-priority thread (also tried
> doing it in the idle task).

Well if you are going to mess with caching make the mapping write-combining
on x86..  You get much better performance.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
