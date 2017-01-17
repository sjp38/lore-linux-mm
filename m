Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65E8F6B026F
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:33:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so283253954pfy.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:33:15 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id f8si24391694pln.60.2017.01.17.01.33.13
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 01:33:14 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170117091543.25850-1-mhocko@kernel.org> <20170117091543.25850-3-mhocko@kernel.org>
In-Reply-To: <20170117091543.25850-3-mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, page_alloc: warn_alloc print nodemask
Date: Tue, 17 Jan 2017 17:32:45 +0800
Message-ID: <034c01d270a4$a9619da0$fc24d8e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'David Rientjes' <rientjes@google.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, January 17, 2017 5:16 PM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> warn_alloc is currently used for to report an allocation failure or an
> allocation stall. We print some details of the allocation request like
> the gfp mask and the request order. We do not print the allocation
> nodemask which is important when debugging the reason for the allocation
> failure as well. We alreaddy print the nodemask in the OOM report.
> 
> Add nodemask to warn_alloc and print it in warn_alloc as well.
> 
> Changes since v1
> - print cpusets as well - Vlastimil
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
