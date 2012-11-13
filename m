Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id C8F616B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 04:36:50 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4787259eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 01:36:49 -0800 (PST)
Date: Tue, 13 Nov 2012 10:36:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 12/19] mm: migrate: Introduce migrate_misplaced_page()
Message-ID: <20121113093644.GA21522@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-13-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352193295-26815-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Note: This was originally based on Peter's patch "mm/migrate: Introduce
> 	migrate_misplaced_page()" but borrows extremely heavily from Andrea's
> 	"autonuma: memory follows CPU algorithm and task/mm_autonuma stats
> 	collection". The end result is barely recognisable so signed-offs
> 	had to be dropped. If original authors are ok with it, I'll
> 	re-add the signed-off-bys.
> 
> Add migrate_misplaced_page() which deals with migrating pages from
> faults.
> 
> Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Based-on-work-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/migrate.h |    8 ++++
>  mm/migrate.c            |  104 ++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 110 insertions(+), 2 deletions(-)

That's a nice patch - the TASK_NUMA_FAULT approach in the 
original patch was not very elegant.

I've started testing it to see how well your version works.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
