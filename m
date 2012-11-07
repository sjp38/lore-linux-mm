Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 382916B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:54:23 -0500 (EST)
Message-ID: <509A4C7C.7020508@redhat.com>
Date: Wed, 07 Nov 2012 06:56:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/19] mm: numa: Migrate on reference policy
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-18-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/06/2012 04:14 AM, Mel Gorman wrote:
> This is the dumbest possible policy that still does something of note.
> When a pte_numa is faulted, it is moved immediately. Any replacement
> policy must at least do better than this and in all likelihood this
> policy regresses normal workloads.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I expect this code to be replaced with a smarter policy.
However, it may be appropriate to merge this into -mm,
and then have the smarter policy implemented on top.

In case we go that route ...

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
