Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4203F6B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 07:24:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i127so17514638wma.15
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 04:24:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g11si15005523wrb.350.2017.07.04.04.24.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 04:24:20 -0700 (PDT)
Date: Tue, 4 Jul 2017 13:24:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH mm] introduce reverse buddy concept to reduce buddy
 fragment
Message-ID: <20170704112414.GA14727@dhcp22.suse.cz>
References: <1498821941-55771-1-git-send-email-zhouxianrong@huawei.com>
 <20170703074829.GD3217@dhcp22.suse.cz>
 <bfb807bf-92ce-27aa-d848-a6cab055447f@huawei.com>
 <20170703153307.GA11848@dhcp22.suse.cz>
 <5c9cf499-6f71-6dda-6378-7e9f27e6cd70@huawei.com>
 <20170704065215.GB12068@dhcp22.suse.cz>
 <d6eaccf6-dbc0-2d4e-2c51-0c9a40b79aa8@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6eaccf6-dbc0-2d4e-2c51-0c9a40b79aa8@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, alexander.h.duyck@intel.com, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, npiggin@gmail.com, kirill.shutemov@linux.intel.com, gi-oh.kim@profitbricks.com, luto@kernel.org, keescook@chromium.org, mark.rutland@arm.com, mingo@kernel.org, heiko.carstens@de.ibm.com, iamjoonsoo.kim@lge.com, rientjes@google.com, ming.ling@spreadtrum.com, jack@suse.cz, ebru.akagunduz@gmail.com, bigeasy@linutronix.de, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, won.ho.park@huawei.com

On Tue 04-07-17 16:04:52, zhouxianrong wrote:
> every 2s i sample /proc/buddyinfo in the whole test process.
> 
> the last about 90 samples were sampled after the test was done.

I've tried to explain to you that numbers without a proper testing
metodology and highlevel metrics you are interested in and comparision
to the base kernel are meaningless. I cannot draw any conclusion from
looking at numbers you have posted. Are high order allocations cheaper
to do with this patch? What about an averge order-0 allocation request?

You are touching memory allocator hot paths and those are really
sensitive to changes. It takes a lot of testing with different workloads
to prove that no new regressions are introduced. That being said, I
completely agree that reducing the memory fragmentation is an important
objective but touching the page allocator and adding new branches there
sounds like a problematic approach which would have to show _huge_
benefits to be mergeable. Is it possible to improve khugepaged to
accomplish the same thing?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
