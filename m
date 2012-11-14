Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1DDBA6B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:18:23 -0500 (EST)
Date: Wed, 14 Nov 2012 18:18:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/31] mm: numa: Only call task_numa_placement for
 misplaced pages
Message-ID: <20121114181817.GO8218@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
 <1352805180-1607-17-git-send-email-mgorman@suse.de>
 <50A3DBCD.8010503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A3DBCD.8010503@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 14, 2012 at 12:58:37PM -0500, Rik van Riel wrote:
> On 11/13/2012 06:12 AM, Mel Gorman wrote:
> >task_numa_placement is potentially very expensive so limit it to being
> >called when a page is misplaced. How necessary this is depends on
> >the placement policy.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> That reads like a premature optimization :)
> 

Hah, touche.

Will shuffle its location in the series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
