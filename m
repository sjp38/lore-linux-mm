Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5649D6B011B
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:06:18 -0400 (EDT)
Date: Mon, 11 Jun 2012 14:06:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120611130612.GA3030@suse.de>
References: <201206041543.56917.b.zolnierkie@samsung.com>
 <4FCD18FD.5030307@gmail.com>
 <4FCD6806.7070609@kernel.org>
 <4FCD713D.3020100@kernel.org>
 <4FCD8C99.3010401@gmail.com>
 <4FCDA1B4.9050301@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FCDA1B4.9050301@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On Tue, Jun 05, 2012 at 03:05:40PM +0900, Minchan Kim wrote:
> > Let's throw it away until the author send us data.
> > 
> 
> I guess it's hard to make such workload to prove it's useful normally.
> But we can't make sure there isn't such workload in the world.
> So I hope listen VOC. At least, Mel might require it.
> 

I'm playing a lot of catch-up at the moment after being out for a few days
so sorry for my silence on this and other threads.

My initial support for this patch was based on an artifical load but one I
felt was plausible to trigger if CMA was being used. In a normal workload
I thought it might be possible to hit if a large process exited freeing
a lot of pagetable pages from MIGRATE_UNMOVABLE blocks at the same time
but that is a little unlikely and a test case would also look very artifical.

Hence, I believe that if you require a real workload to demonstrate the
benefit of the patch that it will be very difficult to find. The primary
decision is if CMA needs this or not. I was under the impression that it
was a help for CMA allocation success rates but I may be mistaken.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
