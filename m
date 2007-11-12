Subject: Re: dio_get_page() lockdep complaints
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1194810546.6098.6.camel@lappy>
References: <20070419073828.GB20928@kernel.dk>
	 <1194627742.6289.175.camel@twins>  <4734992C.7000408@oracle.com>
	 <1194630300.7459.65.camel@heimdal.trondhjem.org>
	 <1194810546.6098.6.camel@lappy>
Content-Type: text/plain
Date: Mon, 12 Nov 2007 09:45:52 +0100
Message-Id: <1194857152.972.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-aio@kvack.org, Chris Mason <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-11-11 at 20:49 +0100, Peter Zijlstra wrote:
> Right, which gets us into all kinds of trouble because some sites need
> mmap_sem to resolve some races, notably s390 31-bit and shm.

You are refering to the mmap_sem use in compat_linux.c:do_mmap2, aren't
you? That check for adresses > 2GB after the call to do_mmap_pgoff can
be removed since arch_get_unmapped_area already checks against
TASK_SIZE. The result of the do_mmap_pgoff call will never be out of
range. This check is a left-over from the early days of the s390 compat
code.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
