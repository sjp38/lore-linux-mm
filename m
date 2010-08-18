Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 107696B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:09:11 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IE5M4s018869
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:05:22 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7IE94F9088458
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:09:04 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IE92xe006423
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:09:04 -0600
Date: Wed, 18 Aug 2010 19:38:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
Message-ID: <20100818140856.GE28417@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201008160949.51512.knikanth@suse.de>
 <201008171039.23701.knikanth@suse.de>
 <1282033475.1926.2093.camel@laptop>
 <201008181452.05047.knikanth@suse.de>
 <1282125536.1926.3675.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1282125536.1926.3675.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nikanth Karthikesan <knikanth@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2010-08-18 11:58:56]:

> On Wed, 2010-08-18 at 14:52 +0530, Nikanth Karthikesan wrote:
> > On Tuesday 17 August 2010 13:54:35 Peter Zijlstra wrote:
> > > On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > > > Oh, nice.  Per-task limit is an elegant solution, which should help
> > > > during most of the common cases.
> > > >
> > > > But I just wonder what happens, when
> > > > 1. The dirtier is multiple co-operating processes
> > > > 2. Some app like a shell script, that repeatedly calls dd with seek and
> > > > skip? People do this for data deduplication, sparse skipping etc..
> > > > 3. The app dies and comes back again. Like a VM that is rebooted, and
> > > > continues writing to a disk backed by a file on the host.
> > > >
> > > > Do you think, in those cases this might still be useful?
> > > 
> > > Those cases do indeed defeat the current per-task-limit, however I think
> > > the solution to that is to limit the amount of writeback done by each
> > > blocked process.
> > > 
> > 
> > Blocked on what? Sorry, I do not understand.
> 
> balance_dirty_pages(), by limiting the work done there (or actually, the
> amount of page writeback completions you wait for -- starting IO isn't
> that expensive), you can also affect the time it takes, and therefore
> influence the impact.
>

There is an ongoing effort to look at per-cgroup dirty limits and I
honestly think it would be nice to do it at that level first. We need
it there as a part of the overall I/O controller. As a specialized
need it could handle your case as well. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
