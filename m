Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B01826B0330
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 04:22:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so4111244pfj.0
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 01:22:57 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l4si810127pgu.396.2017.09.12.01.22.55
        for <linux-mm@kvack.org>;
        Tue, 12 Sep 2017 01:22:56 -0700 (PDT)
Date: Tue, 12 Sep 2017 17:22:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
Message-ID: <20170912082253.GA2875@bbox>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
 <1505183833-4739-4-git-send-email-minchan@kernel.org>
 <87vakopk22.fsf@yhuang-dev.intel.com>
 <20170912062524.GA1950@bbox>
 <874ls8pga3.fsf@yhuang-dev.intel.com>
 <20170912065244.GC2068@bbox>
 <87r2vcnzme.fsf@yhuang-dev.intel.com>
 <20170912075645.GA2837@bbox>
 <87mv60nxwa.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mv60nxwa.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Sep 12, 2017 at 04:07:01PM +0800, Huang, Ying wrote:
< snip >
> >> > My concern is users have been disabled swap readahead by page-cluster would
> >> > be regressed. Please take care of them.
> >> 
> >> How about disable VMA based swap readahead if zram used as swap?  Like
> >> we have done for hard disk?
> >
> > It could be with SWP_SYNCHRONOUS_IO flag which indicates super-fast,
> > no seek cost swap devices if this patchset is merged so VM automatically
> > disables readahead. It is in my TODO but it's orthogonal work.
> >
> > The problem I raised is "Why shouldn't we obey user's decision?",
> > not zram sepcific issue.
> >
> > A user has used SSD as swap devices decided to disable swap readahead
> > by some reason(e.g., small memory system). Anyway, it has worked
> > via page-cluster for a several years but with vma-based swap devices,
> > it doesn't work any more.
> 
> Can they add one more line to their configuration scripts?
> 
> echo 0 > /sys/kernel/mm/swap/vma_ra_max_order

We call it as "regression", don't we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
