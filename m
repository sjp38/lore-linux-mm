Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 471B86B0246
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 22:42:32 -0400 (EDT)
Message-ID: <4E015672.2020407@redhat.com>
Date: Wed, 22 Jun 2011 10:41:54 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <1308587683-2555-2-git-send-email-amwang@redhat.com> <20110620165955.GB9396@suse.de> <4DFF8050.9070201@redhat.com> <20110621093640.GD9396@suse.de>
In-Reply-To: <20110621093640.GD9396@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 17:36, Mel Gorman a??e??:
 >
> Fragmentation avoidance benefits from tuning min_free_kbytes to a higher
> value and minimising fragmentation-related problems is crucial if THP is
> to allocate its necessary pages.
>
> THP tunes min_free_kbytes automatically and this value is in part
> related to the number of zones. At 512M on a single node machine, the
> recommended min_free_kbytes is close to 10% of memory which is barely
> tolerable as it is. At 256M, it's 17%, at 128M, it's 34% so tuning the
> value lower has diminishing returns as the performance impact of giving
> up such a high percentage of free memory is not going to be offset by
> reduced TLB misses. Tuning it to a higher value might make some sense
> if the higher min_free_kbytes was a problem but it would be much more
> rational to tune it as a sysctl than making it a compile-time decision.
>

What this patch changed is the check of total memory pages in hugepage_init(),
which I don't think is suitable as a sysctl.

If you mean min_free_kbytes could be tuned as a sysctl, that should be done
in other patch, right? :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
