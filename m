Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 381626B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 20:24:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b23so6607607wme.3
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 17:24:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor1812210wrl.2.2018.04.03.17.24.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 17:24:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170914132452.d5klyizce72rhjaa@dhcp22.suse.cz>
References: <1504672525-17915-1-git-send-email-iamjoonsoo.kim@lge.com> <20170914132452.d5klyizce72rhjaa@dhcp22.suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Wed, 4 Apr 2018 09:24:06 +0900
Message-ID: <CAAmzW4NGv7RyCYyokPoj4aR3ySKub4jaBZ3k=pt_YReFbByvsw@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-api@vger.kernel.org

Hello, Michal.

Sorry for a really long delay.

2017-09-14 22:24 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> [Sorry for a later reply]
>
> On Wed 06-09-17 13:35:25, Joonsoo Kim wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
>> important to reserve.
>
> I am still not convinced this is a good idea. I do agree that reserving
> memory in both HIGHMEM and MOVABLE is just wasting memory but removing
> the reserve from the highmem as well will result that an oom victim will
> allocate from lower zones and that might have unexpected side effects.

Looks like you are confused.

This patch only affects the situation that ZONE_HIGHMEM and ZONE_MOVABLE is
used at the same time. In that case, before this patch, ZONE_HIGHMEM has
reserve for GFP_HIGHMEM | GFP_MOVABLE request, but, with this patch,  no reserve
in ZONE_HIGHMEM for GFP_HIGHMEM | GFP_MOVABLE request. This perfectly
matchs with your hope. :)

> Can we simply leave HIGHMEM reserve and only remove it from the movable
> zone if both are present?

There is no higher zone than ZONE_MOVABLE so ZONE_MOVABLE has no reserve
with/without this patch. To save memory, we need to remove the reserve in
ZONE_HIGHMEM.

Thanks.
