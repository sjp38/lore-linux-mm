Message-ID: <38CCEADF.A6DE223A@ife.ee.ethz.ch>
Date: Mon, 13 Mar 2000 14:19:27 +0100
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: Re: remap_page_range problem on 2.3.x
References: <20000309175119.28794.qmail@web1306.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Henroid <andy_henroid@yahoo.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Henroid wrote:

> Yes, the remap_page_range is done indirectly
> through mmap call to the /dev/mem driver.

I think I saw this too some time ago.

I tried to duplicate the kernel's view of the
address space above 0xc0000000 at an offset in
a usermode program. I ended up being able to
read the correct data from /dev/mem, but reading
from an mmaped page from /dev/mem returned completely
bogus data (all zero).

My code is in usb.in.tum.de, module usbstress,
files uhcidump.c and kmem*

Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
