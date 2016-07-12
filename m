Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE9356B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 02:33:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hh10so12585461pac.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 23:33:02 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id p186si2410442pfg.235.2016.07.11.23.33.00
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 23:33:01 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com> <20160711152015.e3be8be7702fb0ca4625040d@linux-foundation.org>
In-Reply-To: <20160711152015.e3be8be7702fb0ca4625040d@linux-foundation.org>
Subject: Re: [PATCH] mm, vmscan: Give up balancing node for high order allocations earlier
Date: Tue, 12 Jul 2016 14:32:45 +0800
Message-ID: <013d01d1dc07$33896860$9a9c3920$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Mel Gorman' <mgorman@techsingularity.net>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > To avoid excessive reclaim, we give up rebalancing for high order
> > allocations right after reclaiming enough pages.
> 
> hm.  What are the observed runtime effects of this change?  Any testing
> results?
> 
This work was based on Mel's work, Sir,
"[PATCH 00/27] Move LRU page reclaim from zones to nodes v7".

In "[PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes", 
fragmentation detection is introduced to avoid excessive reclaim. We bail 
out of balancing for high-order allocations if the pages reclaimed at the 
__current__ reclaim priority are two times more than required.

In this work we give up reclaiming for high-order allocations if the 
__total__ number of pages reclaimed, from the first priority to the 
current priority, is more than needed, and in net result we reclaim less 
pages.

Given " [PATCH 00/34] Move LRU page reclaim from zones to nodes v9" 
is delivered, I will send this work if necessary, after Mel's work landing 
in the -mm tree.

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
