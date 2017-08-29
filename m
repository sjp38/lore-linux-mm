Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBB9F6B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:00:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v4so3554926wrc.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 00:00:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y76si763303wme.83.2017.08.29.00.00.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 00:00:18 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
 <20170825002031.GD29701@js1304-P5Q-DELUXE>
 <d57eeb5c-d91d-9718-8473-3c6db465b154@suse.cz>
 <20170828002857.GB9167@js1304-P5Q-DELUXE>
 <78dd0160-14e8-22a6-bd10-d37bbd39f77b@suse.cz>
 <20170829003657.GC14489@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad269513-56e4-87af-f44d-86a5dba1c9f6@suse.cz>
Date: Tue, 29 Aug 2017 09:00:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170829003657.GC14489@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 08/29/2017 02:36 AM, Joonsoo Kim wrote:
> On Mon, Aug 28, 2017 at 08:45:07AM +0200, Vlastimil Babka wrote:
>> +CC linux-api
>>
>> On 08/28/2017 02:28 AM, Joonsoo Kim wrote:
>>> On Fri, Aug 25, 2017 at 09:56:10AM +0200, Vlastimil Babka wrote:
>>>
>>> Seems reasonable. However, if there is a user who checks
>>> sysctl_lowmem_reserve_ratio entry for HIGHMEM and change it, suggested
>>> interface will cause a problem since it doesn't expose ratio for
>>> HIGHMEM. Am I missing something?
>>
>> As you explained, it makes little sense to change it for HIGHMEM which
>> only affects MOVABLE allocations. Also I doubt there are many systems
>> with both HIGHMEM (implies 32bit) *and* MOVABLE (implies NUMA, memory
>> hotplug...) zones. So I would just remove it, and if somebody will
>> really miss it, we can always add it back. In any case, please CC
>> linux-api on the next version.
> 
> If we will accept a change that potentially breaks the user, I think
> that making zero as a special value for sysctl_lowmem_reserve_ratio
> is better solution. How about this way?

I'd prefer removal, but won't object to zero. Certainly much better than
UINT_MAX.

> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
