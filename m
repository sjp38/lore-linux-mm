Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E78D790016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:47:16 -0400 (EDT)
Message-ID: <4E01C80F.8070605@redhat.com>
Date: Wed, 22 Jun 2011 18:46:39 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <1308587683-2555-2-git-send-email-amwang@redhat.com> <20110620165955.GB9396@suse.de> <4DFF8050.9070201@redhat.com> <20110621093640.GD9396@suse.de> <4E015672.2020407@redhat.com> <20110622091611.GB7585@csn.ul.ie>
In-Reply-To: <20110622091611.GB7585@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 17:16, Mel Gorman a??e??:
>
> What I meant was that there is a rational reason why 512M is the
> default for enabling THP by default. Tuning it lower than that by any
> means makes very little sense. Tuning it higher might make some sense
> but it is more likely that THP would simply be disabled via sysctl. I
> see very little advantage to introducing this Kconfig option other
> than as a source of confusion when running make oldconfig.
>

The tunable range is (512, 8192), so 512M is the minimum.

Sure, I knew it can be disabled via /sys, actually we can do even
more in user-space, that is totally move the 512M check out of kernel,
why we didn't?

In short, I think we should either remove the 512M from kernel, or
make 512M to be tunable.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
