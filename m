Date: Wed, 4 Apr 2007 17:27:17 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404152717.GG19587@v2.random>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com> <20070404102407.GA529@wotan.suse.de> <20070404122701.GB19587@v2.random> <20070404135530.GA29026@localdomain> <20070404141457.GF19587@v2.random> <20070404144421.GA13762@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070404144421.GA13762@localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Aloni <da-x@monatomic.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 05:44:21PM +0300, Dan Aloni wrote:
> To refine that example, you could replace the file with a large anonymous 
> memory pool and a lot of swap space committed to it. In that case - with 
> no ZERO_PAGE, would the kernel needlessly swap-out the zeroed pages? 

Swapout or ram is the same in this context. The point is that it will
take 4k either in ram or swap, let's talk about virtual memory without
differentiating between ram or swap.

> Perhaps it's an example too far-fetched to worth considering...

Even if you would read the sparsed file to a malloced space (more
commonly that would be tmpfs) using the read syscall, those anon (or
tmpfs) pages would be _written_ first, which isn't the case we're
discussing here.

You don't know what is on disk, so reading from disk (regardless of
what you read, holes, zeros or anything) provides useful information,
but you know what is in ram after an anon mmap: just zeros, reading
them can't provide useful information to any software.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
