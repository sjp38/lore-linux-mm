Message-ID: <396910CE.64A79820@uow.edu.au>
Date: Sun, 09 Jul 2000 23:54:54 +0000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: sys_exit() and zap_page_range()
References: <3965EC8E.5950B758@uow.edu.au>,
            <3965EC8E.5950B758@uow.edu.au> <20000709103011.A3469@fruits.uzix.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@uzix.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Philipp Rumpf wrote:
> 

Hi, Philipp.

> Here's a simple way:

Already done it :)  It's apparent that not _all_ callers of z_p_r need
this treatment, so I've added an extra 'do_reschedule' flag.  I've also
moved the TLB flushing into this function.

It strikes me that the TLB flush race can be avoided by simply deferring
the actual free_page until _after_ the flush.  So
free_page_and_swap_cache simply appends them to a passed-in list rather
than returning them to the buddy allocator.  zap_page_range can then
free the pages after the flush.

What am I missing???

 
> [PAGE_SIZE*4 is low, I suspect.]

zap_page_range zaps 1000 pages per millisecond, so I'm doing 1000 at a
time.

> For a clean solution, what I would love zap_page_range to look like is:

I'll look at it, but I'm not an MM guy....
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
