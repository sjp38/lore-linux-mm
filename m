Message-ID: <46134124.2040705@yahoo.com.au>
Date: Wed, 04 Apr 2007 16:09:40 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patches] threaded vma patches (was Re: missing madvise functionality)
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <4612DCC6.7000504@cosmosbay.com> <46130BC8.9050905@yahoo.com.au> <46133A8B.50203@cosmosbay.com>
In-Reply-To: <46133A8B.50203@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> Nick Piggin a ecrit :
> 
>> Eric Dumazet wrote:
>>
>>>
>>> I do think such workloads might benefit from a vma_cache not shared 
>>> by all threads but private to each thread. A sequence could 
>>> invalidate the cache(s).
>>>
>>> ie instead of a mm->mmap_cache, having a mm->sequence, and each 
>>> thread having a current->mmap_cache and current->mm_sequence
>>
>>
>> I have a patchset to do exactly this, btw.
> 
> 
> Could you repost it please ?

Sure. I'll send you them privately because they're against an older
kernel.

>> Anyway what is the status of the private futex work. I don't think that
>> is very intrusive or complicated, so it should get merged ASAP (so then
>> at least we have the interface there).
>>
> 
> It seems nobody but you and me cared.

Sad. Although Ulrich did seem interested at one point I think? Ulrich,
do you agree at least with the interface that Eric is proposing? If
yes, then Andrew, do you have any objections to putting Eric's fairly
important patch at least into -mm?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
