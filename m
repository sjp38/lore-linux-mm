Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 380B56B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 20:55:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so22144710pff.6
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 17:55:32 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s36si1038512pld.241.2017.09.12.17.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 17:55:30 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
References: <1505183833-4739-4-git-send-email-minchan@kernel.org>
	<87vakopk22.fsf@yhuang-dev.intel.com> <20170912062524.GA1950@bbox>
	<874ls8pga3.fsf@yhuang-dev.intel.com> <20170912065244.GC2068@bbox>
	<87r2vcnzme.fsf@yhuang-dev.intel.com> <20170912075645.GA2837@bbox>
	<87mv60nxwa.fsf@yhuang-dev.intel.com> <20170912082253.GA2875@bbox>
	<87ingonwpg.fsf@yhuang-dev.intel.com> <20170912233434.GA3686@bbox>
Date: Wed, 13 Sep 2017 08:55:28 +0800
In-Reply-To: <20170912233434.GA3686@bbox> (Minchan Kim's message of "Wed, 13
	Sep 2017 08:34:34 +0900")
Message-ID: <87efrbo1rz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Sep 12, 2017 at 04:32:43PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Tue, Sep 12, 2017 at 04:07:01PM +0800, Huang, Ying wrote:
>> > < snip >
>> >> >> > My concern is users have been disabled swap readahead by page-cluster would
>> >> >> > be regressed. Please take care of them.
>> >> >> 
>> >> >> How about disable VMA based swap readahead if zram used as swap?  Like
>> >> >> we have done for hard disk?
>> >> >
>> >> > It could be with SWP_SYNCHRONOUS_IO flag which indicates super-fast,
>> >> > no seek cost swap devices if this patchset is merged so VM automatically
>> >> > disables readahead. It is in my TODO but it's orthogonal work.
>> >> >
>> >> > The problem I raised is "Why shouldn't we obey user's decision?",
>> >> > not zram sepcific issue.
>> >> >
>> >> > A user has used SSD as swap devices decided to disable swap readahead
>> >> > by some reason(e.g., small memory system). Anyway, it has worked
>> >> > via page-cluster for a several years but with vma-based swap devices,
>> >> > it doesn't work any more.
>> >> 
>> >> Can they add one more line to their configuration scripts?
>> >> 
>> >> echo 0 > /sys/kernel/mm/swap/vma_ra_max_order
>> >
>> > We call it as "regression", don't we?
>> 
>> I think this always happen when we switch default algorithm.  For
>> example, if we had switched default IO scheduler, then the user scripts
>> to configure the parameters of old default IO scheduler will fail.
>
> I don't follow what you are saying with specific example.
> If kernel did it which breaks something on userspace which has worked well,
> it should be fixed. No doubt.
>
> Even although it happened by mistakes, it couldn't be a excuse to break
> new thing, either.
>
> Simple. Fix the regression. 
>
> If you insist on "swap users should fix it by themselves via modification
> of their script or it's not a regression", I don't want to waste my time to
> persuade you any more. I will ask reverting your patches to Andrew.

There is no functionality regression definitely.  It may cause some
performance regression for some users, which could be resolved via some
scripts changing.  Please don't mix them.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
