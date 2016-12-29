Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82DC86B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 03:29:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id u5so523804324pgi.7
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:29:46 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id f3si6778963pga.210.2016.12.29.00.29.44
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 00:29:45 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-8-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-8-mhocko@kernel.org>
Subject: Re: [PATCH 7/7] mm, vmscan: add mm_vmscan_inactive_list_is_low tracepoint
Date: Thu, 29 Dec 2016 16:19:25 +0800
Message-ID: <06db01d261ac$44a57910$cdf06b30$@alibaba-inc.com>
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
> Currently we have tracepoints for both active and inactive LRU lists
> reclaim but we do not have any which would tell us why we we decided to
> age the active list. Without that it is quite hard to diagnose
> active/inactive lists balancing. Add mm_vmscan_inactive_list_is_low
> tracepoint to tell us this information.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
