Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id B53DB6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 04:43:11 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so2308686eek.7
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:43:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si13860131eem.44.2014.05.22.01.43.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:43:10 -0700 (PDT)
Message-ID: <537DB89B.8080301@suse.cz>
Date: Thu, 22 May 2014 10:43:07 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch -mm] mm, thp: avoid excessive compaction latency during
 fault fix
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405072229390.19108@chino.kir.corp.google.com> <5371ED3F.6070505@suse.cz> <alpine.DEB.2.02.1405211945140.13243@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405211945140.13243@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/22/2014 04:49 AM, David Rientjes wrote:
> On Tue, 13 May 2014, Vlastimil Babka wrote:
>
>> I wonder what about a process doing e.g. mmap() with MAP_POPULATE. It seems to
>> me that it would get only MIGRATE_ASYNC here, right? Since gfp_mask would
>> include __GFP_NO_KSWAPD and it won't have PF_KTHREAD.
>> I think that goes against the idea that with MAP_POPULATE you say you are
>> willing to wait to have everything in place before you actually use the
>> memory. So I guess you are also willing to wait for hugepages in that
>> situation?
>>
>
> I don't understand the distinction you're making between MAP_POPULATE and
> simply a prefault of the anon memory.  What is the difference in semantics
> between using MAP_POPULATE and touching a byte every page size along the
> range?  In the latter, you'd be faulting thp with MIGRATE_ASYNC, so I
> don't understand how MAP_POPULATE is any different or implies any
> preference for hugepages.

Hm, OK. It's right we cannot distinguish populating by touching the 
pages manually. Nevermind then.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
