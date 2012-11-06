Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 552B16B002B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 12:32:51 -0500 (EST)
Message-ID: <50994A58.9000309@redhat.com>
Date: Tue, 06 Nov 2012 12:35:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/19] mm: compaction: Add scanned and isolated counters
 for compaction
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/06/2012 04:14 AM, Mel Gorman wrote:
> Compaction already has tracepoints to count scanned and isolated pages
> but it requires that ftrace be enabled and if that information has to be
> written to disk then it can be disruptive. This patch adds vmstat counters
> for compaction called compact_migrate_scanned, compact_free_scanned and
> compact_isolated.
>
> With these counters, it is possible to define a basic cost model for
> compaction. This approximates of how much work compaction is doing and can
> be compared that with an oprofile showing TLB misses and see if the cost of
> compaction is being offset by THP for example. Minimally a compaction patch
> can be evaluated in terms of whether it increases or decreases cost. The
> basic cost model looks like this


> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
