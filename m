Date: Mon, 27 Sep 1999 15:31:28 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <37EF30FF.456EBA6B@kieray1.p.y.ki.era.ericsson.se>
Message-ID: <Pine.LNX.4.10.9909271527030.7835-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> No, you are trying to do _mandatory_ locking enforced by the kernel.
> For cooperative locking on sane GFX hardware a userspace spinlock is
> indeed all that is required, but for the broken hardware you are talking
> about kernel locking would be required.

What are all the broken cards out their? I was reading my old Matrox
Millenium I docs and even that card supports similutaneous access to 
the accel engine and framebuffer. If the number of cards that are that
broken are small then I just will not support them.

> This means that when the accel engine is initiated you must unmap all
> pages of the framebuffer (8k pages on modern cards), install a no-page
> handler and flush the TLBs of all processors.

All the processors!! Thats really bad.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
