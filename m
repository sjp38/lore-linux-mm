Message-ID: <463B1FF6.1030904@redhat.com>
Date: Fri, 04 May 2007 07:58:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au>
In-Reply-To: <463B108C.10602@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ulrich Drepper <drepper@redhat.com>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Rik van Riel wrote:
>> With lazy freeing of anonymous pages through MADV_FREE, performance of
>> the MySQL sysbench workload more than doubles on my quad-core system.
> 
> OK, I've run some tests on a 16 core Opteron system, both sysbench with
> MySQL 5.33 (set up as described in the freebsd vs linux page), and with
> ebizzy.
> 
> What I found is that, on this system, MADV_FREE performance improvement
> was in the noise when you look at it on top of the MADV_DONTNEED glibc
> and down_read(mmap_sem) patch in sysbench.

Interesting, very different results from my system.

First, did you run with the properly TLB batched version of
the MADV_FREE patch?  And did you make sure that MADV_FREE
takes the mmap_sem for reading?   Without that, I did see
a similar thing to what you saw...

Secondly, I'll have to try some test runs one of the larger
systems in the lab.

Maybe the results from my quad core Intel system are not
typical; maybe the results from your 16 core Opteron are
not typical.  Either way, I want to find out :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
