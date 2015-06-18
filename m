Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id D6A736B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 21:26:01 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so32109419qkb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:26:01 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id d68si6325411qka.18.2015.06.17.18.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 18:26:01 -0700 (PDT)
Message-ID: <55821D85.3070208@huawei.com>
Date: Thu, 18 Jun 2015 09:23:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz> <557FDB9B.1090105@huawei.com> <557FF06A.3020000@suse.cz>
In-Reply-To: <557FF06A.3020000@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/16 17:46, Vlastimil Babka wrote:

> On 06/16/2015 10:17 AM, Xishi Qiu wrote:
>> On 2015/6/16 15:53, Vlastimil Babka wrote:
>>
>>> On 06/04/2015 02:54 PM, Xishi Qiu wrote:
>>>>
>>>> I think add a new migratetype is btter and easier than a new zone, so I use
>>>
>>> If the mirrored memory is in a single reasonably compact (no large holes) range
>>> (per NUMA node) and won't dynamically change its size, then zone might be a
>>> better option. For one thing, it will still allow distinguishing movable and
>>> unmovable allocations within the mirrored memory.
>>>
>>> We had enough fun with MIGRATE_CMA and all kinds of checks it added to allocator
>>> hot paths, and even CMA is now considering moving to a separate zone.
>>>
>>
>> Hi, how about the problem of this case:
>> e.g. node 0: 0-4G(dma and dma32)
>>      node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal),
>> so more than one normal zone in a node? or normal zone just span the mirror zone?
> 
> Normal zone can span the mirror zone just fine. However, it will result in zone
> scanners such as compaction to skip over the mirror zone inefficiently. Hmm...
> 

Hi Vlastimil,

If there are many mirror regions in one node, then it will be many holes in the
normal zone, is this fine?

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
