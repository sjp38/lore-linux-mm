Date: Thu, 13 Jan 2000 20:59:06 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001131852.KAA85109@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0001132054060.920-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rik van Riel <riel@nl.linux.org>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Kanoj Sarcar wrote:

>Note that as I point out in my documentation, and as Alan
>also points out, 2.2 is doing fine. The 2.2 code does not
>guarantee dma-zone balancing even if it is empty (if there
>is enough regular free pages). Which means all dma requests
>will fail. I have tried to fix that, since with HIGHMEM, 
>the problem is actually more aggravated.

It's not more aggravated. You fallback in the ISA-DMA zone in the same way
as before.

>I have no idea how having a large number of free dma pages
>ensures more higher-order free pages. Can someone give me
>the logic for this claim?

Probability.

Suppose you have 100mbyte of physical memory. Suppose all 100mbyte are
free. Suppose you want to do a 100mbyte allocation of physically contigous
memory. You'll succeed.

If you have 100mbyte of memory and only half of memory is free. You may
not succeed in allocating 50mbyte of contiguous memory. So the more memory
is free, the more probability you have to succeed in allocating a large
chunk of physically contigous memory.

>Yes, we need to decide whether kswapd needs modification too. Its
>just that I want to do incremental fixes, instead of change a 
>huge bunch of code all at once. The question is, if I had a Linux
>2.3 kernel, where I had completely deleted kswapd(), what problems 
>would the kernel face? Ie, what is kswapd()'s purpose?

I had a pre-2.2.x kernel without kswapd too :). You need kswapd for
machines where noone process ever run and the only thing that runs are
interrupts and bh handlers (e.g. a router).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
