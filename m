Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF17828E2
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 09:24:23 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id jq7so29091448obb.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:24:23 -0800 (PST)
Received: from mail-ob0-x241.google.com (mail-ob0-x241.google.com. [2607:f8b0:4003:c01::241])
        by mx.google.com with ESMTPS id rm7si18848265oeb.42.2016.02.15.06.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 06:24:22 -0800 (PST)
Received: by mail-ob0-x241.google.com with SMTP id kg5so530979obb.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:24:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C1A310.9090305@huawei.com>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
	<CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
	<56C0550F.8020402@huawei.com>
	<20160215024220.GA30918@js1304-P5Q-DELUXE>
	<56C1A310.9090305@huawei.com>
Date: Mon, 15 Feb 2016 23:24:22 +0900
Message-ID: <CAAmzW4MVOh+O1q8WUECTyGYtT=exssvA0WDJy0Y9xBFTpKa1Kg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhong jiang <zhongjiang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2016-02-15 19:06 GMT+09:00 Xishi Qiu <qiuxishi@huawei.com>:
> On 2016/2/15 10:42, Joonsoo Kim wrote:
>
>>>
>>> I have a question about the zone continuity. because hole exists at
>>> arbitrary position in a page block. Therefore, only pageblock_pf_to_page()
>>> is insufficiency, whether pageblock aligned pfn or not , the pfn_valid_within()
>>> is necessary.
>>>
>>> eh: 120M-122M is a range of page block, but the 120.5M-121.5M is holes, only by
>>> pageblock_pfn_to_page() to conclude in the result is inaccurate
>>
>> contiguous may be misleading word. It doesn't represent there are no
>> hole. It only represents that all pageblocks within zone span belong to
>> corresponding zone and validity of all pageblock aligned pfn is
>> checked. So, if it is set, we can safely call pfn_to_page() for pageblock
>> aligned pfn in that zone without checking pfn_valid().
>>
>> Thanks.
>>
>
> Hi Joonsoo,
>
> So "contiguous" here only means that struct page is exist, and don't care whether
> the memory is exist, right?

Yes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
