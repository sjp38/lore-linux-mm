Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 56CFA6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:16:24 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so41080006pad.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 14:16:24 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qc10si5274548pac.160.2015.03.25.14.16.22
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 14:16:23 -0700 (PDT)
Message-ID: <551325A6.5000405@lge.com>
Date: Thu, 26 Mar 2015 06:16:22 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com> <20150325105640.GI4701@suse.de>
In-Reply-To: <20150325105640.GI4701@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com



2015-03-25 i??i?? 7:56i?? Mel Gorman i?'(e??) i?' e,?:
> On Wed, Mar 25, 2015 at 11:39:15AM +0900, Gioh Kim wrote:
>> My driver allocates more than 40MB pages via alloc_page() at a time and
>> maps them at virtual address. Totally it uses 300~400MB pages.
>>
>> If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
>> because-of the external fragmentation.
>>
>> I thought I needed a anti-fragmentation solution for my driver.
>> But there is no allocation function that considers fragmentation.
>> The compaction is not helpful because it is only for movable pages, not unmovable pages.
>>
>> This patch proposes a allocation function allocates only pages in the same pageblock.
>>
>
> Is this not what CMA is for? Or creating a MOVABLE zone?

It's not related to CMA and MOVABLE zone.
It's for compaction and anti-fragmentation for any zone.


>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
