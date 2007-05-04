Message-ID: <463BC686.70901@yahoo.com.au>
Date: Sat, 05 May 2007 09:49:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B1FF6.1030904@redhat.com>
In-Reply-To: <463B1FF6.1030904@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ulrich Drepper <drepper@redhat.com>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>> Rik van Riel wrote:
>>
>>> With lazy freeing of anonymous pages through MADV_FREE, performance of
>>> the MySQL sysbench workload more than doubles on my quad-core system.
>>
>>
>> OK, I've run some tests on a 16 core Opteron system, both sysbench with
>> MySQL 5.33 (set up as described in the freebsd vs linux page), and with
>> ebizzy.
>>
>> What I found is that, on this system, MADV_FREE performance improvement
>> was in the noise when you look at it on top of the MADV_DONTNEED glibc
>> and down_read(mmap_sem) patch in sysbench.
> 
> 
> Interesting, very different results from my system.
> 
> First, did you run with the properly TLB batched version of
> the MADV_FREE patch?  And did you make sure that MADV_FREE
> takes the mmap_sem for reading?   Without that, I did see
> a similar thing to what you saw...

Yes and yes (I initially forgot to add MADV_FREE to the down_read
case and saw horrible performance!)


> Secondly, I'll have to try some test runs one of the larger
> systems in the lab.
> 
> Maybe the results from my quad core Intel system are not
> typical; maybe the results from your 16 core Opteron are
> not typical.  Either way, I want to find out :)

Yep. We might have something like that here, and I'll try with
some other architectures as well next week, if I can get glibc
built.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
