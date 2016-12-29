Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 899F86B0253
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:54:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g1so910998448pgn.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:54:06 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id 33si20463148pll.186.2016.12.28.23.54.04
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 23:54:05 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-5-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-5-mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate tracepoint
Date: Thu, 29 Dec 2016 15:53:49 +0800
Message-ID: <06d801d261a8$b1763600$1462a200$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Rik van Riel' <riel@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Wednesday, December 28, 2016 11:30 PM Michal Hocko wrote: 
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> from is file or anonymous but we do not know which LRU this is. It is
> useful to know whether the list is file or anonymous as well. Change
> the tracepoint to show symbolic names of the lru rather.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
