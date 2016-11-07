Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8406C6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 01:23:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so22968728pfv.5
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 22:23:10 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id fc3si24639336pab.267.2016.11.06.22.23.09
        for <linux-mm@kvack.org>;
        Sun, 06 Nov 2016 22:23:09 -0800 (PST)
Date: Mon, 7 Nov 2016 15:25:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 0/6] Introduce ZONE_CMA
Message-ID: <20161107062501.GB21159@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 14, 2016 at 12:03:10PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello,
> 
> Changes from v5
> o Add acked/reviewed-by tag from Vlastimil and Aneesh
> o Rebase on next-20161013
> o Cosmetic change on patch 1
> o Optimize span of ZONE_CMA on multiple node system

Hello, Andrew.

I got some acked/reviewed-by tags from some of main MM developers who
are actually familiar/associated with this change. Could you merge
this patchset to your tree to get more test coverage?

If I need to do more things to merge this patchset, please let me know
about it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
