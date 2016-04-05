Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 717696B02A4
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 23:40:07 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fe3so1446966pab.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 20:40:07 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id p28si2626333pfi.167.2016.04.04.20.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 20:40:06 -0700 (PDT)
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 5 Apr 2016 13:40:02 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 17F622BB0059
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 13:39:44 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u353dVsC12059124
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 13:39:43 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u353d7eZ023433
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 13:39:07 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] mm/writeback: correct dirty page calculation for highmem
In-Reply-To: <20160405013613.GA27945@js1304-P5Q-DELUXE>
References: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com> <20160405013613.GA27945@js1304-P5Q-DELUXE>
Date: Tue, 05 Apr 2016 09:08:47 +0530
Message-ID: <87a8l8ybaw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> [ text/plain ]
> On Fri, Apr 01, 2016 at 11:10:07AM +0900, js1304@gmail.com wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> 
>> ZONE_MOVABLE could be treated as highmem so we need to consider it for
>> accurate calculation of dirty pages. And, in following patches, ZONE_CMA
>> will be introduced and it can be treated as highmem, too. So, instead of
>> manually adding stat of ZONE_MOVABLE, looping all zones and check whether
>> the zone is highmem or not and add stat of the zone which can be treated
>> as highmem.
>> 
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/page-writeback.c | 8 ++++++--
>>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> Hello, Andrew.
>
> Could you review and merge these simple fixup and cleanup patches?
> I'd like to send ZONE_CMA patchset v2 based on linux-next after this
> series is merged to linux-next.
>

I searched with ZONE_HIGHMEM and AFAICS this series do handle all the
highmem path.

For the series:
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
