Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E86D6B01B0
	for <linux-mm@kvack.org>; Wed, 26 May 2010 15:02:40 -0400 (EDT)
Message-ID: <4BFD7003.9040006@redhat.com>
Date: Wed, 26 May 2010 15:01:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] rename anon_vma_lock to vma_lock_anon_vma
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com> <20100512210216.GP24989@csn.ul.ie> <4BEB18BB.5010803@redhat.com> <20100513095439.GA27949@csn.ul.ie> <20100513103356.25665186@annuminas.surriel.com> <20100513140919.0a037845.akpm@linux-foundation.org> <4BFC9CCF.6000809@redhat.com> <20100526112403.635be0ed@annuminas.surriel.com> <20100526112505.1bddf24d@annuminas.surriel.com> <alpine.LFD.2.00.1005261021560.3689@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1005261021560.3689@i5.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 05/26/2010 01:25 PM, Linus Torvalds wrote:
>
>
> On Wed, 26 May 2010, Rik van Riel wrote:
>>
>> Subject: rename anon_vma_lock to vma_lock_anon_vma
>>
>> Rename anon_vma_lock to vma_lock_anon_vma.  This matches the
>> naming style used in page_lock_anon_vma and will come in really
>> handy further down in this patch series.
>>
>> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> This v2 series seems to be missing all the ack's etc from the previous
> series. At least Mel and Hiroyuki-san had acked several of the patches.
>
> What's the point of making a v2 if it doesn't actually take the input from
> v1 into account?

It did take all the input into account (I made all the
suggested improvements, enhanced comments where people
had questions, etc).

I just forgot to add all the Acked-by's :(

If you want I can send you and Andrew a duplicate of
what I sent this morning, with the only difference
being added Acked-by's.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
