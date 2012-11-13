Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DEEBE6B0087
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:49:27 -0500 (EST)
Message-ID: <50A25DE5.1040202@redhat.com>
Date: Tue, 13 Nov 2012 09:49:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/19] mm: migrate: Introduce migrate_misplaced_page()
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-13-git-send-email-mgorman@suse.de> <20121113093644.GA21522@gmail.com> <20121113114344.GA26305@gmail.com>
In-Reply-To: <20121113114344.GA26305@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/13/2012 06:43 AM, Ingo Molnar wrote:
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>>
>> * Mel Gorman <mgorman@suse.de> wrote:
>>
>>> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>>
>>> Note: This was originally based on Peter's patch "mm/migrate: Introduce
>>> 	migrate_misplaced_page()" but borrows extremely heavily from Andrea's
>>> 	"autonuma: memory follows CPU algorithm and task/mm_autonuma stats
>>> 	collection". The end result is barely recognisable so signed-offs
>>> 	had to be dropped. If original authors are ok with it, I'll
>>> 	re-add the signed-off-bys.
>>>
>>> Add migrate_misplaced_page() which deals with migrating pages from
>>> faults.
>>>
>>> Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
>>> Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>> Based-on-work-by: Andrea Arcangeli <aarcange@redhat.com>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>> ---
>>>   include/linux/migrate.h |    8 ++++
>>>   mm/migrate.c            |  104 ++++++++++++++++++++++++++++++++++++++++++++++-
>>>   2 files changed, 110 insertions(+), 2 deletions(-)
>>
>> That's a nice patch - the TASK_NUMA_FAULT approach in the
>> original patch was not very elegant.
>>
>> I've started testing it to see how well your version works.
>
> Hm, I'm seeing some instability - see the boot crash below. If I
> undo your patch it goes away.
>
> ( To help debugging this I've attached migration.patch which
>    applies your patch on top of Peter's latest queue of patches.
>    If I revert this patch then the crash goes away. )
>
> I've gone back to the well-tested page migration code from Peter
> for the time being.

Is there a place we can see your code?

Peter's patch with MIGRATE_FAULT is very much NAKed, so
this approach does need to be made to work...

You can either make the working tree public somewhere,
so we can help, or figure it out yourself. Your choice :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
