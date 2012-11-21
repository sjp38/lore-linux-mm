Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 46E266B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:20:19 -0500 (EST)
Date: Wed, 21 Nov 2012 17:20:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121121172011.GI8218@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121121170306.GA28811@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 21, 2012 at 06:03:06PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Nov 21, 2012 at 10:21:06AM +0000, Mel Gorman wrote:
> > > 
> > > I am not including a benchmark report in this but will be posting one
> > > shortly in the "Latest numa/core release, v16" thread along with the latest
> > > schednuma figures I have available.
> > > 
> > 
> > Report is linked here https://lkml.org/lkml/2012/11/21/202
> > 
> > I ended up cancelling the remaining tests and restarted with
> > 
> > 1. schednuma + patches posted since so that works out as
> 
> Mel, I'd like to ask you to refer to our tree as numa/core or 
> 'numacore' in the future. Would such a courtesy to use the 
> current name of our tree be possible?
> 

Sure, no problem.

> (We dropped sched/numa long ago and that you still keep 
> referring to it is rather confusing to me.)
> 

Understood.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
