Date: Fri, 25 Aug 2000 11:40:38 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.3.96.1000825124300.23502A-100000@kanga.kvack.org>
References: <20000825153600Z131177-250+6@kanga.kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
Message-Id: <20000825165116Z131177-250+7@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from "Benjamin C.R. LaHaise" <blah@kvack.org> on Fri, 25
Aug 2000 12:45:18 -0400 (EDT)


> > What I'm trying to do is allocate some memory via get_free_pages, and then mark
> > that memory as uncacheable.
> 
> ioremap_nocache should be able to do what you want.

Well, that's what I tried to explain in my previous email which people seem to
be ignoring.

I tried ioremap_nocache, and it doesn't appear to be working.  There are a
number of problems:

1) I'm trying to mark regular RAM as uncacheable, and ioremap_nocache()
requires me to munge the PG_Reservered bit for each page before I can do that. 
Ugly.

2) ioremap_nocache() allocates virtual RAM.  I already have a virtual address,
I don't need another one.

3) The unmap function for ioremap_nocache() is a no-op.  So after I remap and
mark the page as uncacheable, there's no way to restore it after I'm done!

4) Even with all this, it appears that the function isn't working.  I've
attached a logical analyzer to the memory bus, and writes are not being sent
out, leading me to believe the memory is still being cached.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
