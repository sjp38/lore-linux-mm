Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E34526B002B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 12:29:52 -0500 (EST)
Message-ID: <5099499D.4050304@redhat.com>
Date: Tue, 06 Nov 2012 12:32:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/19] mm: compaction: Move migration fail/success stats
 to migrate.c
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/06/2012 04:14 AM, Mel Gorman wrote:
> The compact_pages_moved and compact_pagemigrate_failed events are
> convenient for determining if compaction is active and to what
> degree migration is succeeding but it's at the wrong level. Other
> users of migration may also want to know if migration is working
> properly and this will be particularly true for any automated
> NUMA migration. This patch moves the counters down to migration
> with the new events called pgmigrate_success and pgmigrate_fail.
> The compact_blocks_moved counter is removed because while it was
> useful for debugging initially, it's worthless now as no meaningful
> conclusions can be drawn from its value.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
