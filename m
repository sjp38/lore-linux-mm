Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 71A8E6B00B6
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:27:41 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3584162eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:27:39 -0800 (PST)
Date: Tue, 13 Nov 2012 18:27:34 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/31] Foundation for automatic NUMA balancing V2
Message-ID: <20121113172734.GA12098@gmail.com>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
 <20121113151416.GA20044@gmail.com>
 <20121113154215.GD8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113154215.GD8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > I'd also like to add another, structural side note: you 
> > mixed new vm-stats bits into the whole queue, needlessly 
> > blowing up the size and the mm/ specific portions of the 
> > tree. I'd suggest to post and keep those bits separately, 
> > preferably on top of what we have already once it has 
> > settled down. I'm keeping the 'perf bench numa' bits 
> > separate as well.
> 
> The stats part are fairly late in the queue. I noticed they 
> break build for !CONFIG_BALANCE_NUMA but it was trivially 
> resolved. [...]

Ok - the vm-stats bits are the last larger item remaining that 
I've seen - could you please redo any of your changes on top of 
the latest tip:numa/core tree, to make them easier for me to 
pick up?

Your tree is slowly becoming a rebase of tip:numa/core and that 
will certainly cause problems.

I'll backmerge any delta patches and rebase as necessary - but 
please do them as deltas on top of tip:numa/core to make things 
reviewable and easier to merge:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/core

Thanks!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
