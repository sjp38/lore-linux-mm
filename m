Date: Wed, 11 Oct 2000 23:46:19 +0100 (BST)
From: Chris Evans <chris@scary.beasts.org>
Subject: Re: 2.4.0test9 vm: disappointing streaming i/o under load
In-Reply-To: <39E4E543.8A4EB3BF@norran.net>
Message-ID: <Pine.LNX.4.21.0010112341550.11841-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2000, Roger Larsson wrote:

> Hi,
> 
> (you do have DMA enabled...)

Oh yes (discovering that in fact my chipset is only UDMA33 in the
process).

> I have tested throughput - new kernels are rather good.

I don't doubt it. I'll try and post some numbers on this later.

> I have also tested latency stuff in test9 - I have not
> seen any thing as bad as your results.
> But my audio apps runs with high priority...
> 
> To be able to determine the cause
> Try to to renice your audio deamon (and audio clients)
>  renice -10 <pid>
> 
> 
> Did it become better?

Not noticeably :-(

Perhaps I'm just asking too much, booting with mem=32M. No point testing
the new VM with a 128Mb desktop, though; it wouldn't break a
sweat!

2.2 (RH7.0 kernel) does skip less, though, and the duration of skip is
less.

Perhaps the two kernels have different elevator settings?

Cheers
Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
