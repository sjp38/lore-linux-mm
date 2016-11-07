Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6FB26B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 02:19:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so45721547pfb.6
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 23:19:30 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id x18si29625077pfi.296.2016.11.06.23.14.52
        for <linux-mm@kvack.org>;
        Sun, 06 Nov 2016 23:19:29 -0800 (PST)
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com> <20161107061500.GA21159@js1304-P5Q-DELUXE>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <58202881.5030004@hisilicon.com>
Date: Mon, 7 Nov 2016 15:08:49 +0800
MIME-Version: 1.0
In-Reply-To: <20161107061500.GA21159@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura
 Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016/11/7 14:15, Joonsoo Kim wrote:
> On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
>> Hello, I hava a question on cma zone.
>>
>> When we have cma zone, cma zone will be the highest zone of system.
>>
>> In android system, the most memory allocator is ION. Media system will
>> alloc unmovable memory from it.
>>
>> On low memory scene, will the CMA zone always do balance?
> 
> Allocation request for low zone (normal zone) would not cause CMA zone
> to be balanced since it isn't helpful.
> 
Yes. But the cma zone will run out soon. And it always need to do balance.

How about use migrate cma before movable and let cma type to fallback movable.

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1263745.html

>> Should we transmit the highest available zone to kswapdi 1/4 ?
> 
> It is already done when necessary.
> 
> Thanks.
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
