Date: Fri, 4 Aug 2000 22:17:46 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: RFC: design for new VM
In-Reply-To: <200008050152.SAA89298@apollo.backplane.com>
Message-ID: <Pine.GSO.4.10.10008042211290.7396-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 4 Aug 2000, Matthew Dillon wrote:

> :You have to have some page table locking mechanism for SMP eventually: I
> :think you miss some of the problems because the current FreeBSD SMP stuff
> :is mostly still "big kernel lock" (outdated info?), and you'll end up
> :kicking yourself in a big way when you have the 300 processes sharing the
> :same lock for that region..
> 
>     If it were a long-held lock I'd worry, but if it's a lock on a pte
>     I don't think it can hurt.  After all, even with separate page tables
>     if 300 processes fault on the same backing file offset you are going
>     to hit a bottleneck with MP locking anyway, just at a deeper level
>     (the filesystem rather then the VM system).

Erm... I'm not sure about that - for one thing, you are not caching
results of bmap(). We do. And our VFS is BKL-free, so contention really
hits only on the VOP_BALLOC() level (that can be fixed too, but that's
another story).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
