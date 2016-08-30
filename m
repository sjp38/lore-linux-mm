Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC498308F
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:21:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g124so3023683qkd.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:21:19 -0700 (PDT)
Received: from mail-ua0-x231.google.com (mail-ua0-x231.google.com. [2607:f8b0:400c:c08::231])
        by mx.google.com with ESMTPS id j32si10759812uaj.250.2016.08.30.01.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 01:21:18 -0700 (PDT)
Received: by mail-ua0-x231.google.com with SMTP id m60so20099498uam.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:21:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8737lnudq6.fsf@linux.vnet.ibm.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com> <8737lnudq6.fsf@linux.vnet.ibm.com>
From: Joonsoo Kim <js1304@gmail.com>
Date: Tue, 30 Aug 2016 17:21:18 +0900
Message-ID: <CAAmzW4MZdwn2-Pd_58B+vXKOyPybdfx4FPRvxNaADnDCryo7Ng@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] Introduce ZONE_CMA
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-08-29 18:27 GMT+09:00 Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>:
> js1304@gmail.com writes:
>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Hello,
>>
>> Changes from v4
>> o Rebase on next-20160825
>> o Add general fix patch for lowmem reserve
>> o Fix lowmem reserve ratio
>> o Fix zone span optimizaion per Vlastimil
>> o Fix pageset initialization
>> o Change invocation timing on cma_init_reserved_areas()
>
> I don't see much information regarding how we interleave between
> ZONE_CMA and other zones for movable allocation. Is that explained in
> any of the patch ? The fair zone allocator got removed by
> e6cbd7f2efb433d717af72aa8510a9db6f7a7e05

Interleaving would not work since the fair zone allocator policy is removed.
I don't think that it's a big problem because it is just matter of
timing to fill
up the memory. Eventually, memory on ZONE_CMA will be fully used in
any case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
