Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9E7C6B025E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 03:05:10 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fu3so84539075obb.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 00:05:10 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 189si2062814iou.91.2016.07.05.00.05.08
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 00:05:10 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00e301d1d68b$121ffee0$365ffca0$@alibaba-inc.com>
In-Reply-To: <00e301d1d68b$121ffee0$365ffca0$@alibaba-inc.com>
Subject: Re: [PATCH 23/31] mm, vmscan: Avoid passing in classzone_idx unnecessarily to shrink_node
Date: Tue, 05 Jul 2016 15:04:54 +0800
Message-ID: <00e501d1d68b$88e2d3e0$9aa87ba0$@alibaba-inc.com>
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
> shrink_node receives all information it needs about classzone_idx
> from sc->reclaim_idx so remove the aliases.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 20 +++++++++-----------
>  1 file changed, 9 insertions(+), 11 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
