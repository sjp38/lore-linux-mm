Message-ID: <3AB77443.55B42469@mandrakesoft.com>
Date: Tue, 20 Mar 2001 10:16:19 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva> <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com> <3AB77311.77EB7D60@uow.edu.au>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> General comment: an expensive part of a pagefault
> is zeroing the new page.  It'd be nice if we could
> drop the page_table_lock while doing the clear_user_page()
> and, if possible, copy_user_page() functions.  Very nice.

People have talked before about creating zero pages in the background,
or creating them as a side effect of another operation (don't recall
details), so yeah this is definitely an area where some optimizations
could be done.  I wouldn't want to do it until 2.5 though...

-- 
Jeff Garzik       | May you have warm words on a cold evening,
Building 1024     | a full mooon on a dark night,
MandrakeSoft      | and a smooth road all the way to your door.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
