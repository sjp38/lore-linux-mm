Date: Fri, 30 Jun 2000 16:52:21 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: 2.2: is free_area[] exported?
Message-Id: <20000630220422Z131177-21000+92@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I wrote a driver for Linux 2.4 which traverses the zones and free_area[] arrays
in each zone.  I'm trying to port it back to Linux 2.2, and the first thing I
notice is that there aren't any zones.  No big deal.  However, I also discovered
that the free_area[] global array defined in page_alloc.c is a static variable
and not exported.  Is this true?  Is there any way for a driver to obtain the
address of this variable (without modifying the kernel, of course).



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
