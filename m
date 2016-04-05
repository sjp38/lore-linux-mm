Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 418D56B02A0
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 21:33:56 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n1so51202224pfn.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 18:33:56 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 66si45309429pfl.7.2016.04.04.18.33.54
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 18:33:55 -0700 (PDT)
Date: Tue, 5 Apr 2016 10:36:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/4] mm/writeback: correct dirty page calculation for
 highmem
Message-ID: <20160405013613.GA27945@js1304-P5Q-DELUXE>
References: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 01, 2016 at 11:10:07AM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> ZONE_MOVABLE could be treated as highmem so we need to consider it for
> accurate calculation of dirty pages. And, in following patches, ZONE_CMA
> will be introduced and it can be treated as highmem, too. So, instead of
> manually adding stat of ZONE_MOVABLE, looping all zones and check whether
> the zone is highmem or not and add stat of the zone which can be treated
> as highmem.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page-writeback.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Hello, Andrew.

Could you review and merge these simple fixup and cleanup patches?
I'd like to send ZONE_CMA patchset v2 based on linux-next after this
series is merged to linux-next.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
