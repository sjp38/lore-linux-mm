Date: Wed, 05 Jul 2000 14:01:11 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Allocating memory in a specific zone
Message-Id: <20000705191417Z131198-21002+91@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

What is the proper way, in Linux 2.4, to allocate a block of memory inside a
particular zone?  In this case, I have a pointer to a zone_t (zone_t *zone) and
an order, and I want to allocate a block of memory within that zone of that
particular order.


--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
