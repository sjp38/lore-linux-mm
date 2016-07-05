Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDF5828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 23:18:07 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cx13so162069706pac.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 20:18:07 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id d191si1787223pfg.140.2016.07.04.20.18.05
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 20:18:06 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <009e01d1d5d8$fcf06440$f6d12cc0$@alibaba-inc.com>
In-Reply-To: <009e01d1d5d8$fcf06440$f6d12cc0$@alibaba-inc.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node basis
Date: Tue, 05 Jul 2016 11:17:51 +0800
Message-ID: <00cf01d1d66b$d0eb6eb0$72c24c10$@alibaba-inc.com>
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
> This patch makes reclaim decisions on a per-node basis.  A reclaimer knows
> what zone is required by the allocation request and skips pages from
> higher zones.  In many cases this will be ok because it's a GFP_HIGHMEM
> request of some description.  On 64-bit, ZONE_DMA32 requests will cause
> some problems but 32-bit devices on 64-bit platforms are increasingly
> rare.  Historically it would have been a major problem on 32-bit with big
> Highmem:Lowmem ratios but such configurations are also now rare and even
> where they exist, they are not encouraged.  If it really becomes a
> problem, it'll manifest as very low reclaim efficiencies.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 79 ++++++++++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 55 insertions(+), 24 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
