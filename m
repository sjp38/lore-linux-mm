Subject: Re: dio_get_page() lockdep complaints
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1194857152.972.5.camel@localhost>
References: <20070419073828.GB20928@kernel.dk>
	 <1194627742.6289.175.camel@twins>  <4734992C.7000408@oracle.com>
	 <1194630300.7459.65.camel@heimdal.trondhjem.org>
	 <1194810546.6098.6.camel@lappy>  <1194857152.972.5.camel@localhost>
Content-Type: text/plain
Date: Mon, 12 Nov 2007 10:27:22 +0100
Message-Id: <1194859642.7179.1.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-aio@kvack.org, Chris Mason <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-12 at 09:45 +0100, Martin Schwidefsky wrote:
> On Sun, 2007-11-11 at 20:49 +0100, Peter Zijlstra wrote:
> > Right, which gets us into all kinds of trouble because some sites need
> > mmap_sem to resolve some races, notably s390 31-bit and shm.
> 
> You are refering to the mmap_sem use in compat_linux.c:do_mmap2, aren't
> you? That check for adresses > 2GB after the call to do_mmap_pgoff can
> be removed since arch_get_unmapped_area already checks against
> TASK_SIZE. The result of the do_mmap_pgoff call will never be out of
> range. This check is a left-over from the early days of the s390 compat
> code.

Correct, that is the one I was referring to. Thanks for the explanation,
I'll clean it up when I take this patch forward.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
