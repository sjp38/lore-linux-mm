Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 96CF190016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:15:39 -0400 (EDT)
Date: Wed, 22 Jun 2011 12:15:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
Message-ID: <20110622111525.GK9396@suse.de>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-2-git-send-email-amwang@redhat.com>
 <20110620165955.GB9396@suse.de>
 <4DFF8050.9070201@redhat.com>
 <20110621093640.GD9396@suse.de>
 <4E015672.2020407@redhat.com>
 <20110622091611.GB7585@csn.ul.ie>
 <4E01C80F.8070605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E01C80F.8070605@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, Jun 22, 2011 at 06:46:39PM +0800, Cong Wang wrote:
> ??? 2011???06???22??? 17:16, Mel Gorman ??????:
> >
> >What I meant was that there is a rational reason why 512M is the
> >default for enabling THP by default. Tuning it lower than that by any
> >means makes very little sense. Tuning it higher might make some sense
> >but it is more likely that THP would simply be disabled via sysctl. I
> >see very little advantage to introducing this Kconfig option other
> >than as a source of confusion when running make oldconfig.
> >
> 
> The tunable range is (512, 8192), so 512M is the minimum.
> 
> Sure, I knew it can be disabled via /sys, actually we can do even
> more in user-space, that is totally move the 512M check out of kernel,
> why we didn't?
> 

Because the reason why 512M is the default is not obvious and there
was no guarantee all distros would chose a reasonable default for
an init script (or know that an init script was even necessary).
This is one of the few cases where there is a sensible default that
is the least surprising.

> In short, I think we should either remove the 512M from kernel, or
> make 512M to be tunable.
> 

That just hands them a different sort of rope to hang themselves with
where THP gets enabled on small machines or botting with mem=128M
and getting surprised later by the high min_free_kbytes.

At this point, I don't really care if the Kconfig entry exists or
not. I think it gains nothing but additional confusion for people
who write .config files but it's not a topic I want to discuss for
days either.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
