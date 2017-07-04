Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3898C6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 02:52:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i185so22527731wmi.7
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 23:52:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10si12445525wra.251.2017.07.03.23.52.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 23:52:22 -0700 (PDT)
Date: Tue, 4 Jul 2017 08:52:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH mm] introduce reverse buddy concept to reduce buddy
 fragment
Message-ID: <20170704065215.GB12068@dhcp22.suse.cz>
References: <1498821941-55771-1-git-send-email-zhouxianrong@huawei.com>
 <20170703074829.GD3217@dhcp22.suse.cz>
 <bfb807bf-92ce-27aa-d848-a6cab055447f@huawei.com>
 <20170703153307.GA11848@dhcp22.suse.cz>
 <5c9cf499-6f71-6dda-6378-7e9f27e6cd70@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c9cf499-6f71-6dda-6378-7e9f27e6cd70@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, alexander.h.duyck@intel.com, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, npiggin@gmail.com, kirill.shutemov@linux.intel.com, gi-oh.kim@profitbricks.com, luto@kernel.org, keescook@chromium.org, mark.rutland@arm.com, mingo@kernel.org, heiko.carstens@de.ibm.com, iamjoonsoo.kim@lge.com, rientjes@google.com, ming.ling@spreadtrum.com, jack@suse.cz, ebru.akagunduz@gmail.com, bigeasy@linutronix.de, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, won.ho.park@huawei.com

On Tue 04-07-17 09:21:00, zhouxianrong wrote:
> the test was done as follows:
> 
> 1. the environment is android 7.0 and kernel is 4.1 and managed memory is 3.5GB

There have been many changes in the compaction proper since than. Do you
see the same problem with the current upstream kernel?

> 2. every 4s startup one apk, total 100 more apks need to startup
> 3. after finishing step 2, sample buddyinfo once and get the result

How stable are those results?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
