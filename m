Date: Mon, 25 Sep 2000 17:33:59 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <E13da01-00057k-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0009251727420.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alan Cox wrote:

> Unless Im missing something here think about this case
> 
> 2 active processes, no swap
> 
> #1					#2
> kmalloc 32K				kmalloc 16K
> OK					OK
> kmalloc 16K				kmalloc 32K
> block					block
> 
> so GFP_KERNEL has to be able to fail - it can wait for I/O in some
> cases with care, but when we have no pages left something has to give

you are right, i agree that synchronous OOM for higher-order allocations
must be preserved (just like ATOMIC allocations). But the overwhelming
majority of allocations is done at page granularity.

with multi-page allocations and the need for physically contiguous
buffers, the problem cannot be solved.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
