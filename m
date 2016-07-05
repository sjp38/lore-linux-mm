Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 872666B025E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 03:10:23 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k78so400832152ioi.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 00:10:23 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id n21si2062343ioi.139.2016.07.05.00.10.21
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 00:10:22 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00e901d1d68b$fbfc9e10$f3f5da30$@alibaba-inc.com>
In-Reply-To: <00e901d1d68b$fbfc9e10$f3f5da30$@alibaba-inc.com>
Subject: Re: [PATCH 24/31] mm, vmscan: Avoid passing in classzone_idx unnecessarily to compaction_ready
Date: Tue, 05 Jul 2016 15:10:08 +0800
Message-ID: <00ea01d1d68c$43d25b80$cb771280$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> 
> The scan_control structure has enough information available for
> compaction_ready() to make a decision. The classzone_idx manipulations in
> shrink_zones() are no longer necessary as the highest populated zone is
> no longer used to determine if shrink_slab should be called or not.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 28 ++++++++--------------------
>  1 file changed, 8 insertions(+), 20 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
