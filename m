Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A26616B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:29:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x66so69699711pfb.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:29:08 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id l5si1797611pgh.233.2017.03.01.19.29.06
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:29:07 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-5-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-5-hannes@cmpxchg.org>
Subject: Re: [PATCH 4/9] mm: remove unnecessary reclaimability check from NUMA balancing target
Date: Thu, 02 Mar 2017 11:28:49 +0800
Message-ID: <077f01d29305$1c4e2a90$54ea7fb0$@alibaba-inc.com>
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
> NUMA balancing already checks the watermarks of the target node to
> decide whether it's a suitable balancing target. Whether the node is
> reclaimable or not is irrelevant when we don't intend to reclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
