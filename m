Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6975F6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:39:16 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m101so82516440ioi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:39:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f134si13240100wmf.3.2016.07.13.01.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 01:39:15 -0700 (PDT)
Subject: Re: [PATCH 02/34] mm, vmscan: move lru_lock to the node
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-3-git-send-email-mgorman@techsingularity.net>
 <20160712110604.GA5981@350D> <20160712111805.GD9806@techsingularity.net>
 <20160713055039.GA23860@350D>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <59b2b5d5-cec6-2128-307c-92c2085afd30@suse.cz>
Date: Wed, 13 Jul 2016 10:39:12 +0200
MIME-Version: 1.0
In-Reply-To: <20160713055039.GA23860@350D>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bsingharora@gmail.com, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/13/2016 07:50 AM, Balbir Singh wrote:
> On Tue, Jul 12, 2016 at 12:18:05PM +0100, Mel Gorman wrote:
>> On Tue, Jul 12, 2016 at 09:06:04PM +1000, Balbir Singh wrote:
>>>> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
>>>> index b14abf217239..946e69103cdd 100644
>>>> --- a/Documentation/cgroup-v1/memory.txt
>>>> +++ b/Documentation/cgroup-v1/memory.txt
>>>> @@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
>>>>     Other lock order is following:
>>>>     PG_locked.
>>>>     mm->page_table_lock
>>>> -       zone->lru_lock
>>>> +       zone_lru_lock
>>>
>>> zone_lru_lock is a little confusing, can't we just call it
>>> node_lru_lock?
>>>
>>
>> It's a matter of perspective. People familiar with the VM already expect
>> a zone lock so will be looking for it. I can do a rename if you insist
>> but it may not actually help.
>
> I don't want to insist, but zone_ in the name can be confusing, as to
> leading us to think that the lru_lock is still in the zone

On the other hand, it suggests that the argument of the function is a 
zone. Passing a zone to something called "node_lru_lock()" would be more 
confusing to me. Also it's mostly a convenience wrapper to ease the 
transition, whose usage will likely diminish over time.

> If the rest of the reviewers are fine with, we don't need to rename

Yes, it's not worth the trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
