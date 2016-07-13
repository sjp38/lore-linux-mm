Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A077C6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:10:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so32815896lfg.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:10:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n71si2207530wmg.79.2016.07.13.06.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:10:06 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:10:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] mm, vmscan: Have kswapd reclaim from all zones if
 reclaiming and buffer_heads_over_limit -fix
Message-ID: <20160713131001.GC9905@cmpxchg.org>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468404004-5085-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 11:00:01AM +0100, Mel Gorman wrote:
> Johannes reported that the comment about buffer_heads_over_limit in
> balance_pgdat only made sense in the context of the patch. This patch
> clarifies the reasoning and how it applies to 32 and 64 bit systems.
> 
> This is a fix to the mmotm patch
> mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

This is a great comment now, thank you.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
