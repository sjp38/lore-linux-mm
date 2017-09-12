Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87A806B0332
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 04:32:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m30so13671531pgn.2
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 01:32:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u89si7617043pfi.464.2017.09.12.01.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 01:32:46 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
	<1505183833-4739-4-git-send-email-minchan@kernel.org>
	<87vakopk22.fsf@yhuang-dev.intel.com> <20170912062524.GA1950@bbox>
	<874ls8pga3.fsf@yhuang-dev.intel.com> <20170912065244.GC2068@bbox>
	<87r2vcnzme.fsf@yhuang-dev.intel.com> <20170912075645.GA2837@bbox>
	<87mv60nxwa.fsf@yhuang-dev.intel.com> <20170912082253.GA2875@bbox>
Date: Tue, 12 Sep 2017 16:32:43 +0800
In-Reply-To: <20170912082253.GA2875@bbox> (Minchan Kim's message of "Tue, 12
	Sep 2017 17:22:53 +0900")
Message-ID: <87ingonwpg.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Sep 12, 2017 at 04:07:01PM +0800, Huang, Ying wrote:
> < snip >
>> >> > My concern is users have been disabled swap readahead by page-cluster would
>> >> > be regressed. Please take care of them.
>> >> 
>> >> How about disable VMA based swap readahead if zram used as swap?  Like
>> >> we have done for hard disk?
>> >
>> > It could be with SWP_SYNCHRONOUS_IO flag which indicates super-fast,
>> > no seek cost swap devices if this patchset is merged so VM automatically
>> > disables readahead. It is in my TODO but it's orthogonal work.
>> >
>> > The problem I raised is "Why shouldn't we obey user's decision?",
>> > not zram sepcific issue.
>> >
>> > A user has used SSD as swap devices decided to disable swap readahead
>> > by some reason(e.g., small memory system). Anyway, it has worked
>> > via page-cluster for a several years but with vma-based swap devices,
>> > it doesn't work any more.
>> 
>> Can they add one more line to their configuration scripts?
>> 
>> echo 0 > /sys/kernel/mm/swap/vma_ra_max_order
>
> We call it as "regression", don't we?

I think this always happen when we switch default algorithm.  For
example, if we had switched default IO scheduler, then the user scripts
to configure the parameters of old default IO scheduler will fail.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
