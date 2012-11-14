Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A03226B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 02:52:28 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so99044eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 23:52:27 -0800 (PST)
Date: Wed, 14 Nov 2012 08:52:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/31] Latest numa/core patches, v15
Message-ID: <20121114075222.GA3522@gmail.com>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
 <20121113175428.GF8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113175428.GF8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Nov 13, 2012 at 06:13:23PM +0100, Ingo Molnar wrote:
> > Hi,
> > 
> > This is the latest iteration of our numa/core tree, which
> > implements adaptive NUMA affinity balancing.
> > 
> > Changes in this version:
> > 
> >     https://lkml.org/lkml/2012/11/12/315
> > 
> > Performance figures:
> > 
> >     https://lkml.org/lkml/2012/11/12/330
> > 
> > Any review feedback, comments and test results are welcome!
> > 
> 
> For the purposes of review and testing, this is going to be 
> hard to pick apart and compare. It doesn't apply against 
> 3.7-rc5 [...]

Because the scheduler changes are highly non-trivial it's on top 
of the scheduler tree:

   git pull git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git sched/core

I just tested the patches, they all apply cleanly, with zero 
fuzz and offsets.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
