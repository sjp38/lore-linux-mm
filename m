Date: Thu, 29 Jun 2000 17:59:23 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: __get_free_pages and free_page
Message-Id: <20000629231053Z131172-21003+63@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Let's say I allocate a block of memory with __get_free_pages, which requires
that I specify the order.  To free the memory, I need to call free_pages, also
specifying the same order.

What happens if I specify a smaller order?  Will it free a subset of that block?

Example:

	unsigned long addr;

	addr = __get_free_pages(GFP_ATOMIC, 3);  // allocate 2^3 pages = 32KB

	free_pages(addr, 2);			// frees the 1st 16KB only???

	addr += 16384;				// addr points to 2nd 16KB block

At this point, will addr point to a valid 16KB block of memory?  Will the heap
be intact?  Or will it screw things up?

This is with Linux 2.4.


--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
