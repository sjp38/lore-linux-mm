Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8A9286B00BE
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:54:34 -0500 (EST)
Date: Tue, 13 Nov 2012 17:54:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/31] Latest numa/core patches, v15
Message-ID: <20121113175428.GF8218@suse.de>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Nov 13, 2012 at 06:13:23PM +0100, Ingo Molnar wrote:
> Hi,
> 
> This is the latest iteration of our numa/core tree, which
> implements adaptive NUMA affinity balancing.
> 
> Changes in this version:
> 
>     https://lkml.org/lkml/2012/11/12/315
> 
> Performance figures:
> 
>     https://lkml.org/lkml/2012/11/12/330
> 
> Any review feedback, comments and test results are welcome!
> 

For the purposes of review and testing, this is going to be hard to pick
apart and compare. It doesn't apply against 3.7-rc5 and when trying to
resolve the conflicts it quickly becomes obvious that the series depends
on other scheduler patches such as

sched: Add an rq migration call-back to sched_class
sched: Introduce temporary FAIR_GROUP_SCHED dependency for load-tracking

This is not a full list, it was just the first I hit. What are the other
scheduler patches you are depend on? Knowing that will probably help pick
apart some of the massive patches like "sched, numa, mm: Add adaptive
NUMA affinity support" which is a massive monolithic patch I have not even
attempted to read yet but the diffstat for it alone says a lot.

7 files changed, 901 insertions(+), 197 deletions(-)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
