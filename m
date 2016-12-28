Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5039F6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:40:19 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so27708752wjb.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:40:19 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 15si50833359wml.145.2016.12.28.08.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 08:40:18 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id l2so37204493wml.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:40:18 -0800 (PST)
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <d957d4c5-3b58-c61f-0c95-c59e0326528c@gmail.com>
 <20161228160029.GF11470@dhcp22.suse.cz>
From: Nikolay Borisov <n.borisov.lkml@gmail.com>
Message-ID: <1a8baddb-842d-31d0-dede-3fb04ed5d9ae@gmail.com>
Date: Wed, 28 Dec 2016 18:40:16 +0200
MIME-Version: 1.0
In-Reply-To: <20161228160029.GF11470@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>



On 28.12.2016 18:00, Michal Hocko wrote:
> On Wed 28-12-16 17:50:31, Nikolay Borisov wrote:
>>
>>
>> On 28.12.2016 17:30, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
>>> from is file or anonymous but we do not know which LRU this is. It is
>>> useful to know whether the list is file or anonymous as well. Change
>>
>> Maybe you wanted to say whether the list is ACTIVE/INACTIVE ?
> 
> You are right. I will update the wording to:
> "
> mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> from is file or anonymous but we do not know which LRU this is. It is
> useful to know whether the list is active or inactive as well as we
> use the same function to isolate pages for both of them. Change
> the tracepoint to show symbolic names of the lru rather.
> "
> 
> Does it sound better?

It's better. Just one more nit about the " as well as we
use the same function to isolate pages for both of them"

I think this can be reworded better. The way I understand is - it's
better to know whether it's active/inactive since we are using the same
function to do both, correct? If so then then perhaps the following is a
bit more clear:

"
It is useful to know whether the list is active or inactive, since we
are using the same function to isolate pages from both of them and it's
hard to distinguish otherwise.
"

But as I said - it's a minor nit.


> 
> Thanks!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
