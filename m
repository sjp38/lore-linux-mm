Date: Mon, 25 Sep 2000 18:19:07 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VMt
In-Reply-To: <20000925180448.A25083@gruyere.muc.suse.de>
Message-ID: <Pine.LNX.4.21.0009251817420.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andi Kleen wrote:

> An important exception in 2.2/2.4 is NFS with bigger rsize (will be fixed
> in 2.5, but 2.4 does it this way). For an 8K r/wsize you need reliable 
> (=GFP_ATOMIC) 16K allocations.  

the discussion does not affect GFP_ATOMIC - GFP_ATOMIC allocators *must*
be prepared to handle occasional oom situations gracefully.

> Another thing I would worry about are ports with multiple user page
> sizes in 2.5. Another ugly case is the x86-64 port which has 4K pages
> but may likely need a 16K kernel stack due to the 64bit stack bloat.

yep, but these cases are not affected, i think in the order != 0 case we
should return NULL if a certain number of iterations did not yield any
free page.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
