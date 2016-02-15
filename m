Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7266B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 05:07:56 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wb13so205916207obb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 02:07:56 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j79si16172575oib.97.2016.02.15.02.07.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 02:07:55 -0800 (PST)
Message-ID: <56C1A310.9090305@huawei.com>
Date: Mon, 15 Feb 2016 18:06:08 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com> <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com> <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org> <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com> <56C0550F.8020402@huawei.com> <20160215024220.GA30918@js1304-P5Q-DELUXE>
In-Reply-To: <20160215024220.GA30918@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: zhong jiang <zhongjiang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 2016/2/15 10:42, Joonsoo Kim wrote:

>>
>> I have a question about the zone continuity. because hole exists at
>> arbitrary position in a page block. Therefore, only pageblock_pf_to_page()
>> is insufficiency, whether pageblock aligned pfn or not , the pfn_valid_within()
>> is necessary.
>>
>> eh: 120M-122M is a range of page block, but the 120.5M-121.5M is holes, only by
>> pageblock_pfn_to_page() to conclude in the result is inaccurate
> 
> contiguous may be misleading word. It doesn't represent there are no
> hole. It only represents that all pageblocks within zone span belong to
> corresponding zone and validity of all pageblock aligned pfn is
> checked. So, if it is set, we can safely call pfn_to_page() for pageblock
> aligned pfn in that zone without checking pfn_valid().
> 
> Thanks.
> 

Hi Joonsoo,

So "contiguous" here only means that struct page is exist, and don't care whether
the memory is exist, right?

Thanks,
Xishi Qiu

> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
