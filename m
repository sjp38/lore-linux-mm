Date: Fri, 10 Dec 1999 00:46:34 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Getting big areas of memory, in 2.3.x?
Message-ID: <19991210004634.A3013@fred.muc.de>
References: <Pine.LNX.4.10.9912100021250.10946-100000@chiara.csoma.elte.hu> <199912092332.AAA27593@cave.bitwizard.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199912092332.AAA27593@cave.bitwizard.nl>; from Rogier Wolff on Fri, Dec 10, 1999 at 12:32:01AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rogier Wolff <R.E.Wolff@bitwizard.nl>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 1999 at 12:32:01AM +0100, Rogier Wolff wrote:
> Ingo Molnar wrote:
> > yep, if eg. an fsck happened before modules are loaded then RAM is filled
> > up with the buffer-cache. The best guarantee is to compile such drivers
> > into the kernel.
> 
> My ISDN drivers don't start up correctly after an fsck. 

This is a known bug in the isdn driver. They use a >64K array for their
device structures. The easy fix is to just replace the kmalloc with a 
vmalloc() [the better fix would be to use a array of pointers and allocate
the device structures only when needed]. These are just internal structures
that are never touched by hardware, so vmalloc is fine.

I believe Karsten has fixed it in the latest I4L Tree.


-Andi

---
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
