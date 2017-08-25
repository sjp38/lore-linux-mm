Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 355426B0501
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:49:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p14so2396924wrg.6
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:49:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1si4870336wrd.481.2017.08.25.01.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 01:49:45 -0700 (PDT)
Subject: Re: [PATCH] mm/mlock: use page_zone() instead of page_zone_id()
References: <1503559211-10259-1-git-send-email-iamjoonsoo.kim@lge.com>
 <a8cca363-544d-1b7e-0e93-d7df5c5b6f20@suse.cz>
 <20170824235930.GB29701@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f8f86eed-7613-f1fb-0c3a-b677a4507558@suse.cz>
Date: Fri, 25 Aug 2017 10:48:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170824235930.GB29701@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 08/25/2017 01:59 AM, Joonsoo Kim wrote:
> On Thu, Aug 24, 2017 at 01:05:15PM +0200, Vlastimil Babka wrote:
>> +CC Mel
>>
>> On 08/24/2017 09:20 AM, js1304@gmail.com wrote:
>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>> page_zone_id() is a specialized function to compare the zone for the pages
>>> that are within the section range. If the section of the pages are
>>> different, page_zone_id() can be different even if their zone is the same.
>>> This wrong usage doesn't cause any actual problem since
>>> __munlock_pagevec_fill() would be called again with failed index. However,
>>> it's better to use more appropriate function here.
>>
>> Hmm using zone id was part of the series making munlock faster. Too bad
>> it's doing the wrong thing on some memory models. Looks like it wasn't
>> evaluated in isolation, but only as part of the pagevec usage (commit
>> 7a8010cd36273) but most likely it wasn't contributing too much to the
>> 14% speedup.
> 
> I roughly checked that patch and it seems that performance improvement
> of that commit isn't related to page_zone_id() usage. With
> page_zone(), we would have more chance that do a job as a batch.
> 
>>
>>> This patch is also preparation for futher change about page_zone_id().
>>
>> Out of curiosity, what kind of change?
>>
> 
> I prepared one more patch that prevent another user of page_zone_id()
> since it is too tricky. However, I don't submit it. That description
> should be removed. :/

OK. You can add

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
