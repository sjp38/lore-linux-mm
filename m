Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4218F6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 05:28:17 -0400 (EDT)
Received: by wizk4 with SMTP id k4so194387957wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 02:28:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mb19si1240882wic.69.2015.05.06.02.28.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 02:28:15 -0700 (PDT)
Message-ID: <5549DEAC.6080709@suse.cz>
Date: Wed, 06 May 2015 11:28:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc reserves
 if node has no reclaimable pages
References: <20150327192850.GA18701@linux.vnet.ibm.com> <5515BAF7.6070604@intel.com> <20150327222350.GA22887@linux.vnet.ibm.com> <20150331094829.GE9589@dhcp22.suse.cz> <551E47EF.5030800@suse.cz> <20150403174556.GF32318@linux.vnet.ibm.com> <20150505220913.GC32719@linux.vnet.ibm.com>
In-Reply-To: <20150505220913.GC32719@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 05/06/2015 12:09 AM, Nishanth Aravamudan wrote:
> On 03.04.2015 [10:45:56 -0700], Nishanth Aravamudan wrote:
>>> What I find somewhat worrying though is that we could potentially
>>> break the pfmemalloc_watermark_ok() test in situations where
>>> zone_reclaimable_pages(zone) == 0 is a transient situation (and not
>>> a permanently allocated hugepage). In that case, the throttling is
>>> supposed to help system recover, and we might be breaking that
>>> ability with this patch, no?
>>
>> Well, if it's transient, we'll skip it this time through, and once there
>> are reclaimable pages, we should notice it again.
>>
>> I'm not familiar enough with this logic, so I'll read through the code
>> again soon to see if your concern is valid, as best I can.
>
> In reviewing the code, I think that transiently unreclaimable zones will
> lead to some higher direct reclaim rates and possible contention, but
> shouldn't cause any major harm. The likelihood of that situation, as
> well, in a non-reserved memory setup like the one I described, seems
> exceedingly low.

OK, I guess when a reasonably configured system has nothing to reclaim, 
it's already busted and throttling won't change much.

Consider the patch Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Thanks,
> Nish
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
