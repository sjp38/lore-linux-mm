Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF89E6B0253
	for <linux-mm@kvack.org>; Thu, 12 May 2016 08:05:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so22654601lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:05:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si15873404wjs.138.2016.05.12.05.05.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 05:05:14 -0700 (PDT)
Subject: Re: [PATCH] mm: fix pfn spans two sections in has_unmovable_pages()
References: <57304B9A.40504@huawei.com> <57305AD8.9090202@suse.cz>
 <57306038.1070907@huawei.com> <57346ADA.6050102@suse.cz>
 <57346FD6.6000306@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5734716D.1070401@suse.cz>
Date: Thu, 12 May 2016 14:05:01 +0200
MIME-Version: 1.0
In-Reply-To: <57346FD6.6000306@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/12/2016 01:58 PM, Xishi Qiu wrote:
> On 2016/5/12 19:36, Vlastimil Babka wrote:
>
>> On 05/09/2016 12:02 PM, Xishi Qiu wrote:
>>
>> Sounds ok, please try.
>>
>
> Hi Vlastimil and Naoya,
>
> The mainline doesn't have this problem, because commit
> add05cecef80 ("mm: soft-offline: don't free target page in successful
> page migration") fixed it in v4.2.
>
> I guess the above patch can't be applied to older kernel directly.
> So shall we rewrite a new one or backport the whole patches which it depend?

I think it makes most sense here to write a <4.2 specific patch and send 
it just to stable. If the alternative of backporting add05cecef80 would 
be disruptive, mention that in the changelog. Try to pinpoint the commit 
that introduced the bug so the fix can have a proper "Fixes:" header.

> Thanks,
> Xishi Qiu
>
>>>
>>> Thanks,
>>> Xishi Qiu
>>>
>>>>>         for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>>>>>             unsigned long check = pfn + iter;
>>
>>
>> .
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
