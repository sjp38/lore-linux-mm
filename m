Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5D44F6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 08:28:21 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id h3so10161411igd.4
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 05:28:21 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id c6si6655169icy.97.2014.09.26.05.28.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 05:28:20 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id y20so748308ier.34
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 05:28:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542543D8.8020604@vmware.com>
References: <54246506.50401@hurleysoftware.com>
	<20140925143555.1f276007@as>
	<5424AAD0.9010708@hurleysoftware.com>
	<542512AD.9070304@vmware.com>
	<20140926054005.5c7985c0@as>
	<542543D8.8020604@vmware.com>
Date: Fri, 26 Sep 2014 08:28:19 -0400
Message-ID: <CAF6AEGvOkPq5LQR76-VbspYyCvUxL1=W-dLc4g_aWX2wkUmRpg@mail.gmail.com>
Subject: Re: page allocator bug in 3.16?
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: Chuck Ebbert <cebbert.lkml@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickens <hughd@google.com>, Linux kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Fri, Sep 26, 2014 at 6:45 AM, Thomas Hellstrom <thellstrom@vmware.com> wrote:
> On 09/26/2014 12:40 PM, Chuck Ebbert wrote:
>> On Fri, 26 Sep 2014 09:15:57 +0200
>> Thomas Hellstrom <thellstrom@vmware.com> wrote:
>>
>>> On 09/26/2014 01:52 AM, Peter Hurley wrote:
>>>> On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
>>>>> There are six ttm patches queued for 3.16.4:
>>>>>
>>>>> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
>>>>> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
>>>>> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
>>>>> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
>>>>> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
>>>>> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch
>>>> Thanks for info, Chuck.
>>>>
>>>> Unfortunately, none of these fix TTM dma allocation doing CMA dma allocation,
>>>> which is the root problem.
>>>>
>>>> Regards,
>>>> Peter Hurley
>>> The problem is not really in TTM but in CMA, There was a guy offering to
>>> fix this in the CMA code but I guess he didn't probably because he
>>> didn't receive any feedback.
>>>
>> Yeah, the "solution" to this problem seems to be "don't enable CMA on
>> x86". Maybe it should even be disabled in the config system.
> Or, as previously suggested, don't use CMA for order 0 (single page)
> allocations....

On devices that actually need CMA pools to arrange for memory to be in
certain ranges, I think you probably do want to have order 0 pages
come from the CMA pool.

Seems like disabling CMA on x86 (where it should be unneeded) is the
better way, IMO

BR,
-R


> /Thomas
>
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
