Message-ID: <20010220153722.51795.qmail@web12702.mail.yahoo.com>
Date: Tue, 20 Feb 2001 07:37:22 -0800 (PST)
From: Alan Cudmore <embeddedpenguin@yahoo.com>
Subject: How to allocate large blocks of contiguous physical RAM?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I'm trying to figure out how to allocate a large block
of contiguous physical memory under linux 2.4.x. I
have 4GB of RAM and have turned on the CONFIG_HIGMEM4G
option. 
Previously I was using the "bigphysarea" patch, but
that seems to have a limit of around 900MB. ( is that
because it is being allocated from the 1Gig kernel
physical memory ? )
Also, I have considered changing the PAGE_OFFSET
define to 0x80000000 to give me a little under 2GB.

Ideally I would like to do the following:
1. Pre-Allocate 2 or 3 gigs of contiguous memory
2. A custom PCI 64/66Mhz card will be DMAing data
directly into this memory at very high rates ( up to
500MBytes per second, thus the need for a few gigs ) 
3. Then I would like to be able to DMA data back out
to SCSI without picking the data up ( using SCSI
generic with Direct I/O ).

I really am a linux-MM newbie, so I would appreciate
advice on how I could accomplish such a feat, it it
can be done at all. Any suggestions would be welcome.

Thanks,
Alan C.


__________________________________________________
Do You Yahoo!?
Get personalized email addresses from Yahoo! Mail - only $35 
a year!  http://personal.mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
