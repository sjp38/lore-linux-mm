Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C3C466B01EE
	for <linux-mm@kvack.org>; Wed, 12 May 2010 17:02:10 -0400 (EDT)
Message-ID: <4BEB1732.1010503@redhat.com>
Date: Wed, 12 May 2010 17:01:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] track the root (oldest) anon_vma
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512133958.3aff0515@annuminas.surriel.com> <20100512205941.GO24989@csn.ul.ie>
In-Reply-To: <20100512205941.GO24989@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/12/2010 04:59 PM, Mel Gorman wrote:
> On Wed, May 12, 2010 at 01:39:58PM -0400, Rik van Riel wrote:
>> Subject: track the root (oldest) anon_vma
>>
>> Track the root (oldest) anon_vma in each anon_vma tree.   Because we only
>> take the lock on the root anon_vma, we cannot use the lock on higher-up
>> anon_vmas to lock anything.  This makes it impossible to do an indirect
>> lookup of the root anon_vma, since the data structures could go away from
>> under us.
>>
>> However, a direct pointer is safe because the root anon_vma is always the
>> last one that gets freed on munmap or exit, by virtue of the same_vma list
>> order and unlink_anon_vmas walking the list forward.
>>
>
> Shouldn't this be "usually the last one that gets freed" because of the
> ref-counting by KSM aspect? Minor nit anyway.

It needs to be the last one that gets freed.  Patch 5/5 makes
sure that it is when KSM refcounting is involved.

>> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> Otherwise
>
> Acked-by: Mel Gorman<mel@csn.ul.ie>

Thank you for reviewing these patches.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
