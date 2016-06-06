Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCD0C6B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 11:19:17 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so67518394lfh.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 08:19:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si27267230wjv.201.2016.06.06.08.19.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 08:19:16 -0700 (PDT)
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding the
 zone lock
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <d4d0ec2b-114f-33c0-4d13-bba425fde4bb@suse.cz>
 <CAAmzW4MPf+TW2=mNd_wNPsCSvRrA4e+CMomdZeBekuTdy6Q7dg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1b0e617e-3853-4c8c-2c75-b1d95bfd6ded@suse.cz>
Date: Mon, 6 Jun 2016 17:19:14 +0200
MIME-Version: 1.0
In-Reply-To: <CAAmzW4MPf+TW2=mNd_wNPsCSvRrA4e+CMomdZeBekuTdy6Q7dg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 06/03/2016 02:45 PM, Joonsoo Kim wrote:
> 2016-06-03 19:10 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
>>>
>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>> We don't need to split freepages with holding the zone lock. It will cause
>>> more contention on zone lock so not desirable.
>>>
>>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>>
>> So it wasn't possible to at least move this code from compaction.c to
>> page_alloc.c? Or better, reuse prep_new_page() with some forged
>> gfp/alloc_flags? As we discussed in v1...
>
> Sorry for not mentioning that I did it as a separate patch,
> Please see below link which is the last one within this patchset.
>
> Link: http://lkml.kernel.org/r/1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com

Ah I see. In that case,

Acked-by: Vlastimil Babka <vbabka@suse.cz>


> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
