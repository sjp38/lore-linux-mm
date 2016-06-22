Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 846B26B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 11:30:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so39448152lfg.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:30:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si1535028wma.8.2016.06.22.08.30.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 08:30:49 -0700 (PDT)
Subject: Re: [PATCH 08/27] mm, vmscan: Simplify the logic deciding whether
 kswapd sleeps
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-9-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <66ed4efe-3e23-391f-08fd-c9d6d6a897d8@suse.cz>
Date: Wed, 22 Jun 2016 17:30:41 +0200
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-9-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 04:15 PM, Mel Gorman wrote:
> kswapd goes through some complex steps trying to figure out if it
> should stay awake based on the classzone_idx and the requested order.
> It is unnecessarily complex and passes in an invalid classzone_idx to
> balance_pgdat().  What matters most of all is whether a larger order has
> been requsted and whether kswapd successfully reclaimed at the previous
> order. This patch irons out the logic to check just that and the end result
> is less headache inducing.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

I'm just not entirely convinced that the direct full sleep bypass is worth the 
added complexity. I can even imagine it being counter productive in some 
situations. But it's not a big issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
