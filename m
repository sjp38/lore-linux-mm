Message-ID: <3800B629.209B7A22@colorfullife.com>
Date: Sun, 10 Oct 1999 17:52:09 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.LNX.4.10.9910101713010.364-100000@alpha.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> On Sun, 10 Oct 1999, Manfred Spraul wrote:
> 
> >But this means that both locks are required if you modify the vma list.
> >Single reader, multiple writer synchronization. Unusual, but interesting
> >:-)
> 
> Yes, that's always been this way also in 2.2.x.

and which lock protects "mm->rss"?

It's not an atomic variable, but
* increased by do_swap_page() outside lock_kernel.
* decreased by the swapper.

I've started adding "assert_down()" and "assert_kernellocked()" macros,
and now I don't see the login prompt any more...

eg. sys_mprotect calls merge_segments without lock_kernel().

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
