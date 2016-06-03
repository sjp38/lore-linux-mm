Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 071CE6B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:45:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l14so200818054qke.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:45:15 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id b34si1469589uab.211.2016.06.03.05.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:45:14 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id c189so13107487vkb.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:45:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d4d0ec2b-114f-33c0-4d13-bba425fde4bb@suse.cz>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com> <d4d0ec2b-114f-33c0-4d13-bba425fde4bb@suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 3 Jun 2016 21:45:13 +0900
Message-ID: <CAAmzW4MPf+TW2=mNd_wNPsCSvRrA4e+CMomdZeBekuTdy6Q7dg@mail.gmail.com>
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding the
 zone lock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-06-03 19:10 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
>>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> We don't need to split freepages with holding the zone lock. It will cause
>> more contention on zone lock so not desirable.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>
> So it wasn't possible to at least move this code from compaction.c to
> page_alloc.c? Or better, reuse prep_new_page() with some forged
> gfp/alloc_flags? As we discussed in v1...

Sorry for not mentioning that I did it as a separate patch,
Please see below link which is the last one within this patchset.

Link: http://lkml.kernel.org/r/1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
