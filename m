Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA01823
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 07:17:13 -0500
Date: Mon, 18 Jan 1999 11:00:20 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <m1n23hdopl.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990118104816.5301A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 18 Jan 1999, Eric W. Biederman wrote:

> LT> and (b) as you noticed, it increases fragmentation.
> 
> This is only because he didn't implement any kind of request queue.  A
> fifo queue of pages to write would have keep performance up at current
> levels. 

Infact I didn't wanted having to alloc more memory in order to free memory
(it's something I like to avoid). But the point is that I think that
swapping out from shrink_mmap() even if doing ordered I/O is not a win.
Try, benchmark and let me know your results, maybe I am wrong.  And with a
FIFO also shrink_mmap() would change in order to do what swap_out() is
doing right now. And btw I think that the fifo could be approssimated to a
browse in the swap cache. 

> LT> The reason PG_dirty should be a win for shared mappings is: (a) it gets
> LT> rid of the file write semaphore problem in a very clean way and 
> 
> Nope.  Because we can still have some try to write to file X.
> That write needs memory, and we try to swapout a mapping of file X.
> Unless you believe it implies the write outs then must use a seperate process.

Agreed. I just pointed this out, but maybe I did not understood _where_ we
should do the write to disk to reclaim memory. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
