Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 718FB6B0072
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 18:27:21 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so2748795eaa.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:27:19 -0800 (PST)
Date: Thu, 22 Nov 2012 00:27:15 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121121232715.GA4638@gmail.com>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
 <20121121173316.GA29311@gmail.com>
 <20121121180200.GK8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121121180200.GK8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > I did a quick SPECjbb 32-warehouses run as well:
> > 
> >                                 numa/core      balancenuma-v4
> >       SPECjbb  +THP:               655 k/sec      607 k/sec
> > 
> 
> Cool. Lets see what we have here. I have some questions;
> 
> You say you ran with 32 warehouses. Was this a single run with 
> just 32 warehouses or you did a specjbb run up to 32 
> warehouses and use the figure specjbb spits out? [...]

"32 warehouses" obviously means single instance...

Any multi-instance configuration is explicitly referred to as 
multi-instance. In my numbers I sometimes tabulate them as "4x8 
multi-JVM", that means the obvious as well: 4 instances, 8 
warehouses each.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
