Date: Fri, 21 Jan 2000 20:18:36 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001211353200.486-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001212016180.301-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:

> Since 2.1.x all GFP_KERNEL allocations (not atomic) succeed too.

Alan, I think we've located the bug that made 2.2 kernels
run completely out of memory :)

Andrea, the last few pages are meant for ATOMIC and
PF_MEMALLOC allocations only, otherwise you'll get
deadlock situations.

And don't point me at buggy code that crashes if its
GFP_KERNEL allocation fails. That same code would
also crash if it were allowed to fill up freepages.min
and then run really out of memory...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
