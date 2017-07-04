Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56B946B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 21:23:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s4so224142636pgr.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 18:23:06 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id p19si13549784pgk.10.2017.07.03.18.23.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 18:23:05 -0700 (PDT)
Subject: Re: [PATCH mm] introduce reverse buddy concept to reduce buddy
 fragment
References: <1498821941-55771-1-git-send-email-zhouxianrong@huawei.com>
 <20170703074829.GD3217@dhcp22.suse.cz>
 <bfb807bf-92ce-27aa-d848-a6cab055447f@huawei.com>
 <20170703153307.GA11848@dhcp22.suse.cz>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <5c9cf499-6f71-6dda-6378-7e9f27e6cd70@huawei.com>
Date: Tue, 4 Jul 2017 09:21:00 +0800
MIME-Version: 1.0
In-Reply-To: <20170703153307.GA11848@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, alexander.h.duyck@intel.com, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, npiggin@gmail.com, kirill.shutemov@linux.intel.com, gi-oh.kim@profitbricks.com, luto@kernel.org, keescook@chromium.org, mark.rutland@arm.com, mingo@kernel.org, heiko.carstens@de.ibm.com, iamjoonsoo.kim@lge.com, rientjes@google.com, ming.ling@spreadtrum.com, jack@suse.cz, ebru.akagunduz@gmail.com, bigeasy@linutronix.de, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, won.ho.park@huawei.com

the test was done as follows:

1. the environment is android 7.0 and kernel is 4.1 and managed memory is 3.5GB
2. every 4s startup one apk, total 100 more apks need to startup
3. after finishing step 2, sample buddyinfo once and get the result

On 2017/7/3 23:33, Michal Hocko wrote:
> On Mon 03-07-17 20:02:16, zhouxianrong wrote:
> [...]
>> from above i think after applying the patch the result is better.
>
> You haven't described your testing methodology, nor the workload that was
> tested. As such this data is completely meaningless.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
