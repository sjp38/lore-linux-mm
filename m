Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2956B025E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 03:00:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so557077295pga.4
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:00:52 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id y61si21841228plh.236.2016.12.29.00.00.49
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 00:00:51 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-6-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-6-mhocko@kernel.org>
Subject: Re: [PATCH 5/7] mm, vmscan: extract shrink_page_list reclaim counters into a struct
Date: Thu, 29 Dec 2016 16:00:33 +0800
Message-ID: <06d901d261a9$a2277d70$e6767850$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Rik van Riel' <riel@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>



On Wednesday, December 28, 2016 11:31 PM Michal Hocko wrote: 
> From: Michal Hocko <mhocko@suse.com>
> 
> shrink_page_list returns quite some counters back to its caller. Extract
> the existing 5 into struct reclaim_stat because this makes the code
> easier to follow and also allows further counters to be returned.
> 
> While we are at it, make all of them unsigned rather than unsigned long
> as we do not really need full 64b for them (we never scan more than
> SWAP_CLUSTER_MAX pages at once). This should reduce some stack space.
> 
> This patch shouldn't introduce any functional change.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
