From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906281955.MAA06984@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
Date: Mon, 28 Jun 1999 12:55:23 -0700 (PDT)
In-Reply-To: <Pine.BSO.4.10.9906281530400.24888-100000@funky.monkey.org> from "Chuck Lever" at Jun 28, 99 03:39:43 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> i'm already working on a patch that will allow kswapd to grab the mmap_sem
> for the task that is about to be swapped.  this takes a slightly different
> approach, since i'm focusing on kswapd and not on swapoff.  essentially
> the patch does two things:

So, I would think some (if not mine) swapoff fix is still needed ...

> 
> 1)  it separates the logic of try_to_free_pages() and kswapd.  kswapd now
> does the swapping, while try_to_free_pages() only does the shrink_mmap()
> phase.
> 
> 2)  after kswapd has chosen a process to swap, it drops the kernel lock
> and grabs the mmap_sem for the thing it's about to swap.  it picks up the
> kernel lock at appropriate points lower in the code.
>

Agreed this would be a nice thing to be able to do ... 
Other than the deadlock problem, there's another issue involved, I 
think. Processes can go to sleep (inside drivers/fs for example while
mmaping/munmaping/faulting) holding their mmap_sem, so any solution 
should be able to guarantee that (at least one of) the memory free'ers 
do not go to sleep indefinitely (or for some time that is upto driver/fs
code to determine).

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
