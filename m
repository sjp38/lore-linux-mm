Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5046B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 23:52:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u81so279251653oia.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 20:52:01 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id i141si1574435ioa.48.2016.07.04.20.51.58
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 20:52:00 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00d601d1d670$42904f50$c7b0edf0$@alibaba-inc.com>
In-Reply-To: <00d601d1d670$42904f50$c7b0edf0$@alibaba-inc.com>
Subject: Re: [PATCH 10/31] mm, vmscan: remove duplicate logic clearing node congestion and dirty state
Date: Tue, 05 Jul 2016 11:51:44 +0800
Message-ID: <00d701d1d670$8c94ac90$a5be05b0$@alibaba-inc.com>
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
> Reclaim may stall if there is too much dirty or congested data on a node.
> This was previously based on zone flags and the logic for clearing the
> flags is in two places.  As congestion/dirty tracking is now tracked on a
> per-node basis, we can remove some duplicate logic.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
