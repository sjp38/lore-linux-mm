Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 914F16B006E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:03:09 -0500 (EST)
Message-ID: <50AA582E.30602@redhat.com>
Date: Mon, 19 Nov 2012 11:02:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/19, v2] mm/migrate: Introduce migrate_misplaced_page()
References: <1353083121-4560-1-git-send-email-mingo@kernel.org> <1353083121-4560-18-git-send-email-mingo@kernel.org> <20121119022558.GA3186@gmail.com>
In-Reply-To: <20121119022558.GA3186@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On 11/18/2012 09:25 PM, Ingo Molnar wrote:
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>
>> Add migrate_misplaced_page() which deals with migrating pages from
>> faults.
>>
>> This includes adding a new MIGRATE_FAULT migration mode to
>> deal with the extra page reference required due to having to look up
>> the page.
> [...]
>
>> --- a/include/linux/migrate_mode.h
>> +++ b/include/linux/migrate_mode.h
>> @@ -6,11 +6,14 @@
>>    *	on most operations but not ->writepage as the potential stall time
>>    *	is too significant
>>    * MIGRATE_SYNC will block when migrating pages
>> + * MIGRATE_FAULT called from the fault path to migrate-on-fault for mempolicy
>> + *	this path has an extra reference count
>>    */
>
> Note, this is still the older, open-coded version.
>
> The newer replacement version created from Mel's patch which
> reuses migrate_pages() and is nicer on out-of-node-memory
> conditions and is cleaner all around can be found below.
>
> I tested it today and it appears to work fine. I noticed no
> performance improvement or performance drop from it - if it
> holds up in testing it will be part of the -v17 release of
> numa/core.

Excellent. That gets rid of the last issue with numa/base :)


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
