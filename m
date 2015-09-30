Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4956B026C
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 10:43:03 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so201977178wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 07:43:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si1254523wie.9.2015.09.30.07.43.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 07:43:02 -0700 (PDT)
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for order-0
 allocations
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
 <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
 <20150909123901.GA12432@techsingularity.net>
 <CAMJBoFORrhY++4PeT1xcvHCU=tyNs4T0uMhoUxrKsru6QC1NWw@mail.gmail.com>
 <560BE934.3030808@suse.cz>
 <CAMJBoFOKGchN7LQny+tsWd-wL0LVyt8NL+7FZE__TvskanFhsg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560BF4F4.9010000@suse.cz>
Date: Wed, 30 Sep 2015 16:43:00 +0200
MIME-Version: 1.0
In-Reply-To: <CAMJBoFOKGchN7LQny+tsWd-wL0LVyt8NL+7FZE__TvskanFhsg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/30/2015 04:16 PM, Vitaly Wool wrote:
>>>>>
>>>>
>>>> So what do you suggest instead? A fixed number, some other heuristic?
>>>> You have pushed several times now for the series to focus on the latency
>>>> of standard high-order allocations but again I will say that it is
>>>> outside
>>>> the scope of this series. If you want to take steps to reduce the latency
>>>> of ordinary high-order allocation requests that can sleep then it should
>>>> be a separate series.
>>>
>>>
>>> I do believe https://lkml.org/lkml/2015/9/9/313 does a better job
>>
>>
>> Does a better job regarding what exactly? It does fix the CMA-specific
>> issue, but so does this patch - without affecting allocation fastpaths by
>> making them update another counter. But the issues discussed here are not
>> related to that CMA problem.
>
> Let me disagree. Guaranteeing one suitable high-order page is not
> enough, so the suggested patch does not work that well for me.
> Existing broken watermark calculation doesn't work for me either, as
> opposed to the one with my patch applied. Both solutions are related
> to the CMA issue but one does make compaction work harder and cause
> bigger latencies -- why do you think these are not related?

Well you didn't mention which issues you have with this patch. If you 
did measure bigger latencies and more compaction work, please post the 
numbers and details about the test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
