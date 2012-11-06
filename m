Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3BCEF6B002B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 12:31:25 -0500 (EST)
Message-ID: <50994A02.3030005@redhat.com>
Date: Tue, 06 Nov 2012 12:33:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/19] mm: migrate: Add a tracepoint for migrate_pages
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/06/2012 04:14 AM, Mel Gorman wrote:
> The pgmigrate_success and pgmigrate_fail vmstat counters tells the user
> about migration activity but not the type or the reason. This patch adds
> a tracepoint to identify the type of page migration and why the page is
> being migrated.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
