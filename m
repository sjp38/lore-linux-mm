Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C12D6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:44:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a190so858968978pgc.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:44:13 -0800 (PST)
Received: from out0-139.mail.aliyun.com (out0-139.mail.aliyun.com. [140.205.0.139])
        by mx.google.com with ESMTP id t3si21431140plj.319.2016.12.28.23.44.12
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 23:44:12 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-3-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-3-mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Date: Thu, 29 Dec 2016 15:44:06 +0800
Message-ID: <06d301d261a7$558f8ef0$00aeacd0$@alibaba-inc.com>
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
> Our reclaim process has several tracepoints to tell us more about how
> things are progressing. We are, however, missing a tracepoint to track
> active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> the number of scanned, rotated, deactivated and freed pages from the
> particular node's active list.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
