Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 461926B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:01:30 -0500 (EST)
Message-ID: <50A3DC54.8010206@redhat.com>
Date: Wed, 14 Nov 2012 13:00:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/31] mm: numa: Avoid double faulting after migrating
 misplaced page
References: <1352805180-1607-1-git-send-email-mgorman@suse.de> <1352805180-1607-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-18-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/13/2012 06:12 AM, Mel Gorman wrote:
> The pte_same check after a misplaced page is successfully migrated will
> never succeed and force a double fault to fix it up as pointed out by Rik
> van Riel. This was the "safe" option but it's expensive.
>
> This patch uses the migration allocation callback to record the location
> of the newly migrated page. If the page is the same when the PTE lock is
> reacquired it is assumed that it is safe to complete the pte_numa fault
> without incurring a double fault.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
