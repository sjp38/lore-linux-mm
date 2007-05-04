Message-ID: <463BC62C.3060605@yahoo.com.au>
Date: Sat, 05 May 2007 09:47:56 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com>
In-Reply-To: <463B598B.80200@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> Nick Piggin wrote:
> 
>>What I found is that, on this system, MADV_FREE performance improvement
>>was in the noise when you look at it on top of the MADV_DONTNEED glibc
>>and down_read(mmap_sem) patch in sysbench.
> 
> 
> I don't want to judge the numbers since I cannot but I want to make an
> observations: even if in the SMP case MADV_FREE turns out to not be a
> bigger boost then there is still the UP case to keep in mind where Rik
> measured a significant speed-up.  As long as the SMP case isn't hurt
> this is reaosn enough to use the patch.  With more and more cores on one
> processor SMP systems are pushed evermore to the high-end side.  You'll
> find many installations which today use SMP will be happy enough with
> many-core UP machines.

OK, sure. I think we need more numbers though.

And even if this was a patch with _no_ possibility for regressions and it
was a completely trivial one that improves performance in some cases...
one big problem is that it uses another page flag.

I literally have about 4 or 5 new page flags I'd like to add today :) I
can't of course, because we have very few spare ones left.

 From the MySQL numbers on this system, it seems like performance is in the
noise, and MADV_DONTNEED makes the _vast_ majority of the improvement.
This is also the case with Rik's benchmarks, and while he did see some
improvement, I found the runs to be quite variable, so it would be ideal
to get a larger sample.

And the fact that the poor behaviour of the old style malloc/free went
unnoticed for so long indicates that it won't be the end of the world if
we didn't merge MADV_FREE right now.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
