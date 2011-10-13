Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 219F56B0031
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 11:54:36 -0400 (EDT)
Date: Thu, 13 Oct 2011 10:54:30 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111013152355.GB6966@sgi.com>
Message-ID: <alpine.DEB.2.00.1110131052300.18473@router.home>
References: <20111012160202.GA18666@sgi.com> <20111012120118.e948f40a.akpm@linux-foundation.org> <alpine.DEB.2.00.1110121452220.31218@router.home> <20111013152355.GB6966@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 13 Oct 2011, Dimitri Sivanich wrote:

> > increase the allowed delta per zone if frequent updates occur via the
> > overflow checks in vmstat.c. See calculate_*_threshold there.
>
> I tried changing the threshold in both directions, with slower throughput in
> both cases.

If that is the case check for the vm_stat cacheline being shared with
another hot kernel variable variable. Maybe that causes cacheline
eviction.

If there are no updates occurring for a while (due to increased deltas
and/or vmstat updates) then the vm_stat cacheline should be able to stay
in shared mode in multiple processors and the performance should increase.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
