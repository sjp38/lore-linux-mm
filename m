Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA696B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 02:01:23 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so24716000obc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 23:01:22 -0700 (PDT)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id n9si8726530oed.53.2015.03.17.23.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 23:01:22 -0700 (PDT)
Received: by obdfc2 with SMTP id fc2so24681289obd.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 23:01:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <873854ard7.fsf@linux.vnet.ibm.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
	<873854ard7.fsf@linux.vnet.ibm.com>
Date: Wed, 18 Mar 2015 15:01:22 +0900
Message-ID: <CAAmzW4P5ReRndwt1Z2QdyZUvvC5F7uEpNGL_w9jYFHfp84orcw@mail.gmail.com>
Subject: Re: [RFC 00/16] Introduce ZONE_CMA
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

2015-03-17 18:46 GMT+09:00 Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>
>> I passed boot test on x86, ARM32 and ARM64. I did some stress tests
>> on x86 and there is no problem. Feel free to enjoy and please give me
>> a feedback. :)
>
> Tested on ppc64 with kvm. (I used the CONFIG_SPARSEMEM_VMEMMAP). I will
> check with other sparsemem config and update if I find any issue.

Wow!
Really thanks for testing this patchset.
I will test more and if any error is found, will notify soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
