Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 798036B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:59:26 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id d2so18499741obp.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 01:59:26 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id q85si7850482itc.78.2016.07.12.01.59.23
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 01:59:25 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com> <20160711152015.e3be8be7702fb0ca4625040d@linux-foundation.org> <013d01d1dc07$33896860$9a9c3920$@alibaba-inc.com> <20160712083342.GC9806@techsingularity.net>
In-Reply-To: <20160712083342.GC9806@techsingularity.net>
Subject: Re: [PATCH] mm, vmscan: Give up balancing node for high order allocations earlier
Date: Tue, 12 Jul 2016 16:48:38 +0800
Message-ID: <000001d1dc1a$2f3afb30$8db0f190$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> This decision
> was based on the fact the series did not appear to be over-reclaiming for
> high-order pages when compared with zone-lru.
> 
Then dropped.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
