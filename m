Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 96CB36B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 06:46:00 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id lj1so4536792pab.9
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:46:00 -0700 (PDT)
Received: from smtp-outbound-1.vmware.com (smtp-outbound-1.vmware.com. [208.91.2.12])
        by mx.google.com with ESMTPS id bl7si8559685pdb.165.2014.09.26.03.45.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 03:45:59 -0700 (PDT)
Message-ID: <542543D8.8020604@vmware.com>
Date: Fri, 26 Sep 2014 12:45:44 +0200
From: Thomas Hellstrom <thellstrom@vmware.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com>	<20140925143555.1f276007@as> <5424AAD0.9010708@hurleysoftware.com>	<542512AD.9070304@vmware.com> <20140926054005.5c7985c0@as>
In-Reply-To: <20140926054005.5c7985c0@as>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten
 Lankhorst <maarten.lankhorst@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On 09/26/2014 12:40 PM, Chuck Ebbert wrote:
> On Fri, 26 Sep 2014 09:15:57 +0200
> Thomas Hellstrom <thellstrom@vmware.com> wrote:
>
>> On 09/26/2014 01:52 AM, Peter Hurley wrote:
>>> On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
>>>> There are six ttm patches queued for 3.16.4:
>>>>
>>>> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
>>>> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
>>>> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
>>>> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
>>>> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
>>>> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch
>>> Thanks for info, Chuck.
>>>
>>> Unfortunately, none of these fix TTM dma allocation doing CMA dma allocation,
>>> which is the root problem.
>>>
>>> Regards,
>>> Peter Hurley
>> The problem is not really in TTM but in CMA, There was a guy offering to
>> fix this in the CMA code but I guess he didn't probably because he
>> didn't receive any feedback.
>>
> Yeah, the "solution" to this problem seems to be "don't enable CMA on
> x86". Maybe it should even be disabled in the config system.
Or, as previously suggested, don't use CMA for order 0 (single page)
allocations....

/Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
