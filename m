Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 556C76B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 19:39:57 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so782217pbb.25
        for <linux-mm@kvack.org>; Tue, 20 May 2014 16:39:57 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id rc8si12976326pab.132.2014.05.20.16.39.55
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 16:39:56 -0700 (PDT)
Message-ID: <537BE7CA.4030706@lge.com>
Date: Wed, 21 May 2014 08:39:54 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE> <537AFED0.4010401@lge.com> <20140520083206.GA8927@js1304-P5Q-DELUXE>
In-Reply-To: <20140520083206.GA8927@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>



2014-05-20 i??i?? 5:32, Joonsoo Kim i?' e,?:
> On Tue, May 20, 2014 at 04:05:52PM +0900, Gioh Kim wrote:
>> That case, device-specific coherent memory allocation, is handled at dma_alloc_coherent in arm_dma_alloc.
>> __dma_alloc handles only general coherent memory allocation.
>>
>> I'm sorry missing mention about it.
>>
>
> Hello,
>
> AFAIK, *coherent* memory allocation is different with *contiguous* memory
> allocation(CMA). So we need to handle the case I mentioned.

Yes, I confused the coherent memory aand contiguous memory. It's my mistake.

So I checked dma_alloc_from_contiguous and found dev_get_cma_area function.
The dev_get_cma_area returns device-specific cma if it exists or default global-cma.
I think __alloc_from_contiguous doesn't distinguish device-specific cma area and global cma.
The purpose of __alloc_from_contiguous is allocation of contiguous memory from any cma area, not device-specific area.

If my assumption is right, __alloc_from_contiguous can be replaced with __alloc_remap_buffer without checking device-specific cma area.

What do you think about it?

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
