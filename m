Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE1E6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:38:19 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id p65so231792953wmp.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:38:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m192si17323531wmg.14.2016.03.23.05.38.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 05:38:17 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: prevent merging between isolated and other
 pageblocks
References: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
 <56F2803E.70100@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F28E35.1080107@suse.cz>
Date: Wed, 23 Mar 2016 13:38:13 +0100
MIME-Version: 1.0
In-Reply-To: <56F2803E.70100@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leizhen <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, Lucas Stach <l.stach@pengutronix.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Laura Abbott <labbott@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, stable@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 03/23/2016 12:38 PM, Hanjun Guo wrote:
> On 2016/3/23 17:40, Vlastimil Babka wrote:
>> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
>> Link: https://lkml.org/lkml/2016/3/2/280
>> Reported-by: Hanjun Guo <guohanjun@huawei.com>
>
> With the same stress test case (alloc/free cma) running for more than
> one hour, the bug I reported is gone.
>
> Tested-by: Hanjun Guo <guohanjun@huawei.com>

I wanted to add that, but forgot. Thanks!
I also forgot to transfer:

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

> Thanks for debugging!
> Hanjun
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
