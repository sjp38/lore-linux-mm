Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07AAE6B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 07:07:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44-v6so1009822wrt.9
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 04:07:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5-v6si1508529edd.95.2018.04.27.04.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Apr 2018 04:07:00 -0700 (PDT)
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in /proc/vmstat
References: <20180425191422.9159-1-guro@fb.com>
 <20180426200331.GZ17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804261453460.238822@chino.kir.corp.google.com>
 <99208563-1171-b7e7-a0d7-b47b6c5e2307@suse.cz>
 <20180427105549.GA8127@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <30986543-bd47-80bc-354c-727792f86547@suse.cz>
Date: Fri, 27 Apr 2018 13:06:56 +0200
MIME-Version: 1.0
In-Reply-To: <20180427105549.GA8127@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>

On 04/27/2018 12:55 PM, Roman Gushchin wrote:
> On Fri, Apr 27, 2018 at 11:17:01AM +0200, Vlastimil Babka wrote:
>> On 04/26/2018 11:55 PM, David Rientjes wrote:
>>>
>>> Implementing this counter as a vmstat doesn't make much sense based on how 
>>> it's used.  Do you have a link to what Vlastimil proposed?  I haven't seen 
>>> mention of alternative ideas.
>>
>> It was in the original thread, see e.g.
>> <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
>>
>> However it will take some time to get that in mainline, and meanwhile
>> the current implementation does prevent a DOS. So I doubt it can be
>> fully reverted - as a compromise I just didn't want the counter to
>> become ABI. TBH though, other people at LSF/MM didn't seem concerned
>> that /proc/vmstat is an ABI that we can't change (i.e. counters have
>> been presumably removed in the past already).
>>
> 
> Thank you, Vlastimil!
> That pretty much matches my understanding of the case.
> 
> BTW, are you planning to work on supporting reclaimable objects
> by slab allocators?

Yeah, soon!

Vlastimil

> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
