Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 342F06B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:48:18 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IEgB9t008310
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:42:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7IEmEq0131572
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:48:14 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IEmDUG016305
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:48:14 -0300
Date: Wed, 18 Aug 2010 20:18:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
Message-ID: <20100818144809.GF28417@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201008160949.51512.knikanth@suse.de>
 <201008171039.23701.knikanth@suse.de>
 <1282033475.1926.2093.camel@laptop>
 <201008181452.05047.knikanth@suse.de>
 <1282125536.1926.3675.camel@laptop>
 <20100818140856.GE28417@balbir.in.ibm.com>
 <1282141518.1926.4048.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1282141518.1926.4048.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nikanth Karthikesan <knikanth@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2010-08-18 16:25:18]:

> On Wed, 2010-08-18 at 19:38 +0530, Balbir Singh wrote:
> 
> > There is an ongoing effort to look at per-cgroup dirty limits and I
> > honestly think it would be nice to do it at that level first. We need
> > it there as a part of the overall I/O controller. As a specialized
> > need it could handle your case as well. 
> 
> Well, it would be good to isolate that to the cgroup code. Also from
> what I understood, the plan was to simply mark dirty inodes with a
> cgroup and use that from writeout_inodes() to write out inodes
> specifically used by that cgroup.
> 
> That is, on top of what Andrea Righi already proposed, which would
> provide the actual per cgroup dirty limit (although the per-bdi
> proportions applied to a cgroup limit aren't strictly correct, but that
> seems to be something you'll have to live with, a per-bdi-per-cgroup
> proportion would simply be accounting insanity).
> 
> That is a totally different thing than what was proposed.

Understood, I was indirectly trying to get Nikanth to look at cgroups
since he was interested in the dirtier (as in task).


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
