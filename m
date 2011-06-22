Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B075E90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 05:16:17 -0400 (EDT)
Date: Wed, 22 Jun 2011 10:16:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
Message-ID: <20110622091611.GB7585@csn.ul.ie>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-2-git-send-email-amwang@redhat.com>
 <20110620165955.GB9396@suse.de>
 <4DFF8050.9070201@redhat.com>
 <20110621093640.GD9396@suse.de>
 <4E015672.2020407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E015672.2020407@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, Jun 22, 2011 at 10:41:54AM +0800, Cong Wang wrote:
> ??? 2011???06???21??? 17:36, Mel Gorman ??????:
> >
> >Fragmentation avoidance benefits from tuning min_free_kbytes to a higher
> >value and minimising fragmentation-related problems is crucial if THP is
> >to allocate its necessary pages.
> >
> >THP tunes min_free_kbytes automatically and this value is in part
> >related to the number of zones. At 512M on a single node machine, the
> >recommended min_free_kbytes is close to 10% of memory which is barely
> >tolerable as it is. At 256M, it's 17%, at 128M, it's 34% so tuning the
> >value lower has diminishing returns as the performance impact of giving
> >up such a high percentage of free memory is not going to be offset by
> >reduced TLB misses. Tuning it to a higher value might make some sense
> >if the higher min_free_kbytes was a problem but it would be much more
> >rational to tune it as a sysctl than making it a compile-time decision.
> >
> 
> What this patch changed is the check of total memory pages in hugepage_init(),
> which I don't think is suitable as a sysctl.
> 
> If you mean min_free_kbytes could be tuned as a sysctl, that should be done
> in other patch, right? :)
> 

min_free_kbytes is already automatically tuned when THP is enabled.

What I meant was that there is a rational reason why 512M is the
default for enabling THP by default. Tuning it lower than that by any
means makes very little sense. Tuning it higher might make some sense
but it is more likely that THP would simply be disabled via sysctl. I
see very little advantage to introducing this Kconfig option other
than as a source of confusion when running make oldconfig.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
