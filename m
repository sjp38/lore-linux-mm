Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8C4A6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 06:08:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x6so244599699oif.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 03:08:44 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id w64si774064iof.8.2016.07.04.03.08.42
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 03:08:44 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <009e01d1d5d8$fcf06440$f6d12cc0$@alibaba-inc.com>
In-Reply-To: <009e01d1d5d8$fcf06440$f6d12cc0$@alibaba-inc.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node basis
Date: Mon, 04 Jul 2016 18:08:27 +0800
Message-ID: <00a301d1d5dc$02643ca0$072cb5e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> @@ -2561,17 +2580,23 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	 * highmem pages could be pinning lowmem pages storing buffer_heads
>  	 */
>  	orig_mask = sc->gfp_mask;
> -	if (buffer_heads_over_limit)
> +	if (buffer_heads_over_limit) {
>  		sc->gfp_mask |= __GFP_HIGHMEM;
> +		sc->reclaim_idx = classzone_idx = gfp_zone(sc->gfp_mask);
> +	}
> 
We need to push/pop ->reclaim_idx as ->gfp_mask handled?

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
