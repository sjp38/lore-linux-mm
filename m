Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2124C6B005C
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 05:12:22 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so2459215ieb.10
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 02:12:21 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id fg11si6666247icb.51.2014.08.29.02.12.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 02:12:21 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h15so2290589igd.14
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 02:12:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140829081211.GF12424@suse.de>
References: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
	<20140829081211.GF12424@suse.de>
Date: Fri, 29 Aug 2014 17:12:21 +0800
Message-ID: <CAL1ERfN9bjwGDr8=KXhSHGNCFZTw-A1+hY8Lbyr8nTmvwE3gxQ@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: avoid wakeup kswapd on the unintended node
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, rientjes@google.com, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Aug 29, 2014 at 4:12 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Fri, Aug 29, 2014 at 03:03:19PM +0800, Weijie Yang wrote:
>> When enter page_alloc slowpath, we wakeup kswapd on every pgdat
>> according to the zonelist and high_zoneidx. However, this doesn't
>> take nodemask into account, and could prematurely wakeup kswapd on
>> some unintended nodes.
>>
>> This patch uses for_each_zone_zonelist_nodemask() instead of
>> for_each_zone_zonelist() in wake_all_kswapds() to avoid the above situation.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>
> Just out of curiousity, did you measure a problem due to this or is
> the patch due to code inspection? It was known that we examined useless
> nodes but assumed to not be a problem because the watermark check should
> prevent spurious wakeups.  However, we do a cpuset check and this patch
> is consistent with that so regardless of why you wrote the patch

It is a patch due to code review :-)

> Acked-by: Mel Gorman <mgorman@suse.de>
>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
