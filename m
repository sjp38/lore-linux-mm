Date: Fri, 25 Aug 2000 10:25:26 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.3.96.1000824193751.16795A-100000@kanga.kvack.org>
References: <20000824233129Z131177-247+8@kanga.kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
Message-Id: <20000825153600Z131177-250+6@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from "Benjamin C.R. LaHaise" <blah@kvack.org> on Thu, 24
Aug 2000 19:43:41 -0400 (EDT)


> >  Basically, what I'm
> > trying to do is find the pte for a given physical page.  That is, I'm looking
> > for a function that looks like this:
> > 
> > pte_t *find_pte(mem_map_t *mm);
> > 
> > Given a pointer to a mem_map_t, it returns the pointer to the pte_t for that
> > physical page.  Is there such a function?  I've found things like this:
> 
> There is no such function, and there cannot be for kernel addresses
> since on most x86s, the kernel makes use of 4MB pages to map chunks of
> memory.  If you're looking for the user addresses associated with a
> physical page, there are several ways of doing so, but none of them are
> implemented in the current kernel.

I thought that memory that's not allocated by a user process (i.e. allocated by
a driver that calls get_free_pages) doesn't have a user address.  Is that wrong?

> 
> Why do you need this/what are you trying to do?

What I'm trying to do is allocate some memory via get_free_pages, and then mark
that memory as uncacheable.


--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
