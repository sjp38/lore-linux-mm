Date: Wed, 05 Jul 2000 16:13:52 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Tell me about ZONE_DMA
Message-Id: <20000705212704Z131198-21004+106@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm trying to understand the differences between the three zones, ZONE_DMA,
ZONE_NORMAL,and ZONE_HIGHMEM.  I've searched the source code (I'm getting pretty
good at understanding the kernel memory allocator), but I can't figure out what
physical regions of memory belong to each zone.  Where is that determined?

Also, I get this eerie feeling that it's possible for a physical page to exist
in more than one zone.  Is that true?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
