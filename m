Message-ID: <20021004134259.41743.qmail@web12802.mail.yahoo.com>
Date: Fri, 4 Oct 2002 06:42:59 -0700 (PDT)
From: sreekanth reddy <reddy_cdi@yahoo.com>
Subject: remap_page_range() beyond 4GB 
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

How can I "remap_page_range()" for physical addresses
beyond 4GB ? . remap_page_range()takes a 32 bit
(unsigned long) value which cannot address > 4GB
physical memory.

Thanks,

Sreekanth Reddy

__________________________________________________
Do you Yahoo!?
New DSL Internet Access from SBC & Yahoo!
http://sbc.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
