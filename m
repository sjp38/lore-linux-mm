Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 16:16:56 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> from "Ingo Molnar" at Sep 25, 2000 05:16:06 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13da01-00057k-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > GFP_KERNEL has to be able to fail for 2.4. Otherwise you can get
> > everything jammed in kernel space waiting on GFP_KERNEL and if the
> > swapper cannot make space you die.
> 
> if one can get everything jammed waiting for GFP_KERNEL, and not being
> able to deallocate anything, thats a VM or resource-limit bug. This
> situation is just 1% RAM away from the 'root cannot log in', situation.

Unless Im missing something here think about this case

2 active processes, no swap

#1					#2
kmalloc 32K				kmalloc 16K
OK					OK
kmalloc 16K				kmalloc 32K
block					block

so GFP_KERNEL has to be able to fail - it can wait for I/O in some cases with
care, but when we have no pages left something has to give


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
