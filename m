Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55D786B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:23:35 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id f14so24735018lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:23:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si21027024wjh.93.2016.05.13.01.23.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 01:23:34 -0700 (PDT)
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57358F03.5080707@suse.cz>
Date: Fri, 13 May 2016 10:23:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160512162043.GA4261@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/12/2016 06:20 PM, Michal Hocko wrote:
> On Tue 10-05-16 09:35:56, Vlastimil Babka wrote:
> [...]
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 570383a41853..0cb09714d960 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -256,8 +256,7 @@ struct vm_area_struct;
>>   #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>>   #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
>>   #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
>> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
>> -			 ~__GFP_RECLAIM)
>> +			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>
> I am not sure this is the right thing to do. I think we should keep
> __GFP_NORETRY and clear it where we want a stronger semantic. This is
> just too suble that all callsites are doing the right thing.

That would complicate alloc_hugepage_direct_gfpmask() a bit, but if you 
think it's worth it, I can turn the default around, OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
