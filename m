Subject: Re: the new VM
Date: Mon, 25 Sep 2000 15:47:03 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu> from "Ingo Molnar" at Sep 25, 2000 03:12:58 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dZX7-00055f-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Because as you said the machine can lockup when you run out of memory.
> 
> well, i think all kernel-space allocations have to be limited carefully,
> denying succeeding allocations is not a solution against over-allocation,
> especially in a multi-user environment.

GFP_KERNEL has to be able to fail for 2.4. Otherwise you can get everything
jammed in kernel space waiting on GFP_KERNEL and if the swapper cannot make
space you die.

The alternative approach where it cannot fail has to be at higher levels so
you can release other resources that might need freeing for deadlock avoidance
before you retry


Alan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
