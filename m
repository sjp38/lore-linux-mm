Message-ID: <3AB8F9A5.FC0095FB@mandrakesoft.com>
Date: Wed, 21 Mar 2001 13:57:41 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: kmalloc with GFP_DMA, or get_free_pages!!!
References: <85256A16.0067FBE4.00@alpha2.storage.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <jganapat@Storage.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Jalajadevi Ganapathy wrote:
> 
> I could not find that file in the Documentation directory.

It's in kernel 2.4:
> [jgarzik@rum linux_2_4]$ ls -l Documentation/DM*
> -rw-r--r--    1 jgarzik  jgarzik     15302 Mar  7 04:00 Documentation/DMA-mapping.txt

> I have one more question here. I read from a book that  virt_to_phy is same
> as virt_to_bus for PCI devices. Is that True?

On some platforms yes, on some, no.  Nevertheless, in kernel 2.4.x at
least, do not use virt_to_bus and virt_to_phys, use DMA mapping... 
Using virt_to_bus will kill the link step on some platforms.

-- 
Jeff Garzik       | May you have warm words on a cold evening,
Building 1024     | a full mooon on a dark night,
MandrakeSoft      | and a smooth road all the way to your door.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
