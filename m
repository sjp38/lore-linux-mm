Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5A9C6B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 19:34:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so22590549pfl.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 16:34:37 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 3si9285402plx.833.2017.09.12.16.34.35
        for <linux-mm@kvack.org>;
        Tue, 12 Sep 2017 16:34:36 -0700 (PDT)
Date: Wed, 13 Sep 2017 08:34:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
Message-ID: <20170912233434.GA3686@bbox>
References: <1505183833-4739-4-git-send-email-minchan@kernel.org>
 <87vakopk22.fsf@yhuang-dev.intel.com>
 <20170912062524.GA1950@bbox>
 <874ls8pga3.fsf@yhuang-dev.intel.com>
 <20170912065244.GC2068@bbox>
 <87r2vcnzme.fsf@yhuang-dev.intel.com>
 <20170912075645.GA2837@bbox>
 <87mv60nxwa.fsf@yhuang-dev.intel.com>
 <20170912082253.GA2875@bbox>
 <87ingonwpg.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ingonwpg.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Sep 12, 2017 at 04:32:43PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Tue, Sep 12, 2017 at 04:07:01PM +0800, Huang, Ying wrote:
> > < snip >
> >> >> > My concern is users have been disabled swap readahead by page-cluster would
> >> >> > be regressed. Please take care of them.
> >> >> 
> >> >> How about disable VMA based swap readahead if zram used as swap?  Like
> >> >> we have done for hard disk?
> >> >
> >> > It could be with SWP_SYNCHRONOUS_IO flag which indicates super-fast,
> >> > no seek cost swap devices if this patchset is merged so VM automatically
> >> > disables readahead. It is in my TODO but it's orthogonal work.
> >> >
> >> > The problem I raised is "Why shouldn't we obey user's decision?",
> >> > not zram sepcific issue.
> >> >
> >> > A user has used SSD as swap devices decided to disable swap readahead
> >> > by some reason(e.g., small memory system). Anyway, it has worked
> >> > via page-cluster for a several years but with vma-based swap devices,
> >> > it doesn't work any more.
> >> 
> >> Can they add one more line to their configuration scripts?
> >> 
> >> echo 0 > /sys/kernel/mm/swap/vma_ra_max_order
> >
> > We call it as "regression", don't we?
> 
> I think this always happen when we switch default algorithm.  For
> example, if we had switched default IO scheduler, then the user scripts
> to configure the parameters of old default IO scheduler will fail.

I don't follow what you are saying with specific example.
If kernel did it which breaks something on userspace which has worked well,
it should be fixed. No doubt.

Even although it happened by mistakes, it couldn't be a excuse to break
new thing, either.

Simple. Fix the regression. 

If you insist on "swap users should fix it by themselves via modification
of their script or it's not a regression", I don't want to waste my time to
persuade you any more. I will ask reverting your patches to Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
