Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 559756B025F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 06:53:16 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id 127so92171757wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:53:16 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTP id vv8si4310817wjc.192.2016.03.30.03.53.13
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 03:53:15 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/page_alloc: protect pcp->batch accesses with
 ACCESS_ONCE"
References: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
 <20160330103839.GA4773@techsingularity.net>
From: Hekuang <hekuang@huawei.com>
Message-ID: <56FBAFA0.3010604@huawei.com>
Date: Wed, 30 Mar 2016 18:51:12 +0800
MIME-Version: 1.0
In-Reply-To: <20160330103839.GA4773@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, cody@linux.vnet.ibm.com, gilad@benyossef.com, kosaki.motohiro@gmail.com, mgorman@suse.de, penberg@kernel.org, lizefan@huawei.com, wangnan0@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

hi

a?? 2016/3/30 18:38, Mel Gorman a??e??:
> On Wed, Mar 30, 2016 at 10:22:07AM +0000, He Kuang wrote:
>> This reverts commit 998d39cb236fe464af86a3492a24d2f67ee1efc2.
>>
>> When local irq is disabled, a percpu variable does not change, so we can
>> remove the access macros and let the compiler optimize the code safely.
>>
> batch can be changed from other contexts. Why is this safe?
>
I've mistakenly thought that per_cpu variable can only be accessed by 
that cpu.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
