Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9160C6B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 03:39:00 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so19200622wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 00:39:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u129si3320839wmd.50.2016.03.10.00.38.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 00:38:59 -0800 (PST)
Subject: Re: [PATCH v2 0/5] introduce kcompactd and stop compacting in kswapd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <20160309155238.GK27018@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E1329F.3040600@suse.cz>
Date: Thu, 10 Mar 2016 09:38:55 +0100
MIME-Version: 1.0
In-Reply-To: <20160309155238.GK27018@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/09/2016 04:52 PM, Michal Hocko wrote:
> On Mon 08-02-16 14:38:06, Vlastimil Babka wrote:
>> The previous RFC is here [1]. It didn't have a cover letter, so the description
>> and results are in the individual patches.
>
> FWIW I think this is a step in the right direction. I would give my

Thanks!

> Acked-by to all patches but I wasn't able to find time for a deep review
> and my lack of knowledge of compaction details doesn't help much. I do
> agree that conflating kswapd with compaction didn't really work out well
> and fixing this would just make the code more complex and would more
> prone to new bugs.

Yeah, it seems that direct reclaim/compaction is complex enough already...

> In future we might want to invent something similar
> to watermarks and set an expected level of high order pages prepared for
> the allocation (e.g. have at least XMB of memory in order-9+). kcompact
> then could try as hard as possible to provide them. Does that sound at
> least doable?

Sure, that was/is part of the plan. But I was trimming the series for 
initial merge over the past year to arrive at a starting point where 
reaching consensus is easier.

> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
