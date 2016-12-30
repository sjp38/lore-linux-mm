Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA9106B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:38:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so601677194pgi.7
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:38:47 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id n77si24447624pfj.225.2016.12.30.01.38.45
        for <linux-mm@kvack.org>;
        Fri, 30 Dec 2016 01:38:46 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-3-mhocko@kernel.org> <20161229053359.GA1815@bbox> <20161229075243.GA29208@dhcp22.suse.cz> <20161230014853.GA4184@bbox> <20161230092636.GA13301@dhcp22.suse.cz>
In-Reply-To: <20161230092636.GA13301@dhcp22.suse.cz>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Date: Fri, 30 Dec 2016 17:38:28 +0800
Message-ID: <001b01d26280$7a5ee120$6f1ca360$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Minchan Kim' <minchan@kernel.org>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Rik van Riel' <riel@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>


On Friday, December 30, 2016 5:27 PM Michal Hocko wrote: 
> Anyway, what do you think about this updated patch? I have kept Hillf's
> A-b so please let me know if it is no longer valid.
> 
My mind is not changed:)

Happy new year folks!

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
