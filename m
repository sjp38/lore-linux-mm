Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBC16B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:33:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so581442505pfb.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:33:20 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id 128si20881288pgg.245.2016.12.28.23.33.17
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 23:33:19 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-2-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-2-mhocko@kernel.org>
Subject: Re: [PATCH 1/7] mm, vmscan: remove unused mm_vmscan_memcg_isolate
Date: Thu, 29 Dec 2016 15:33:01 +0800
Message-ID: <06d201d261a5$c9248e80$5b6dab80$@alibaba-inc.com>
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
> the trace point is not used since 925b7673cce3 ("mm: make per-memcg LRU
> lists exclusive") so it can be removed.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
