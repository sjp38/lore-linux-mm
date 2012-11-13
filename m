Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 24D686B0074
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:14:28 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3519431eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 07:14:26 -0800 (PST)
Date: Tue, 13 Nov 2012 16:14:16 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/31] Foundation for automatic NUMA balancing V2
Message-ID: <20121113151416.GA20044@gmail.com>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> (Since I wrote this changelog there has been another release 
> of schednuma. I had delayed releasing this series long enough 
> and decided not to delay further. Of course, I plan to dig 
> into that new revision and see what has changed.)

Thanks, I've picked up a number of cleanups from your series and 
propagated them into tip:numa/core tree.

FYI, in addition to the specific patches to which I replied to 
earier today, I've also propagated all your:

   CONFIG_SCHED_NUMA -> CONFIG_BALANCE_NUMA

renames thoughout the patches - I fundamentally agree that 
CONFIG_BALANCE_NUMA is a better, more generic name.

My structural criticism of the architecture specific bits of 
your patch-queue still applies to this version as well. That 
change inflicted much of the changes that you had to do to 
Peter's patches. It blew up the size of your tree and forks the 
code into per architecture variants for no good reason.

Had you not done that and had you kept the code generic you'd 
essentially end up close to where tip:numa/core is today.

So if we can clear that core issue up we'll have quite a bit of 
agreement.

I'd also like to add another, structural side note: you mixed 
new vm-stats bits into the whole queue, needlessly blowing up 
the size and the mm/ specific portions of the tree. I'd suggest 
to post and keep those bits separately, preferably on top of 
what we have already once it has settled down. I'm keeping the 
'perf bench numa' bits separate as well.

Anyway, I've applied all applicable cleanups from you and picked 
up Peter's latest code with the modifications I've indicated in 
that thread, to the latest tip:numa/core tree, which I'll send 
out for review in the next hour or so.

This version is supposed to address all review feedback received 
so far: it refines the MM specific split-up of the patches, 
fixes regressions - see the changelogs for more details.

I'll (re-)send the full series of the latest patches and any 
additional feedback will be welcome.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
