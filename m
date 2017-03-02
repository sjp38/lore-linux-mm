Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6669F6B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:34:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t184so78490648pgt.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:34:51 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id i9si6321359plk.73.2017.03.01.19.34.49
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:34:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-8-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-8-hannes@cmpxchg.org>
Subject: Re: [PATCH 7/9] mm: delete NR_PAGES_SCANNED and pgdat_reclaimable()
Date: Thu, 02 Mar 2017 11:34:34 +0800
Message-ID: <078201d29305$e98da760$bca8f620$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On March 01, 2017 5:40 AM Johannes Weiner wrote: 
> 
> NR_PAGES_SCANNED counts number of pages scanned since the last page
> free event in the allocator. This was used primarily to measure the
> reclaimability of zones and nodes, and determine when reclaim should
> give up on them. In that role, it has been replaced in the preceeding
> patches by a different mechanism.
> 
> Being implemented as an efficient vmstat counter, it was automatically
> exported to userspace as well. It's however unlikely that anyone
> outside the kernel is using this counter in any meaningful way.
> 
> Remove the counter and the unused pgdat_reclaimable().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
