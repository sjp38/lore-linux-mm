Date: Fri, 6 Apr 2001 22:21:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: memory allocation problems
In-Reply-To: <Pine.LNX.4.30.0104061227240.25381-100000@mf1.private>
Message-ID: <Pine.LNX.4.21.0104062211470.1572-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wayne Whitney <whitney@math.berkeley.edu>
Cc: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, majer@endeca.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Wayne Whitney wrote:
> 
> As was pointed out to me in January, another solution for i386 would be to
> fix a maximum stack size and have the mmap() allocations grow downward
> from the "top" of the stack (3GB - max stack size).  I'm not sure why that
> is not currently done.

I'd be interested in the answer to that too.  Typically, the memory
layout has ELF text at the lowest address, starting at 0x08048000 -
which is a curious place to put it, until you realize that if you
place the stack below it, you can use (in a typical small program)
just one page table for stack + text + data (then another for mmaps
and shared libs from 3GB down): two page tables instead of present three.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
