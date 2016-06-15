Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E29976B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:28:05 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id jf8so10597672lbc.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:28:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x141si16925811lfd.47.2016.06.15.07.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 07:28:04 -0700 (PDT)
Subject: Re: [PATCH 07/27] mm, vmscan: Remove balance gap
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <686f13b7-a80b-d7e2-a057-6e5822866648@suse.cz>
Date: Wed, 15 Jun 2016 16:28:03 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> The balance gap was introduced to apply equal pressure to all zones when
> reclaiming for a higher zone. With node-based LRU, the need for the balance
> gap is removed and the code is dead so remove it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c | 19 ++++++++-----------
>  1 file changed, 8 insertions(+), 11 deletions(-)

Also this:
include/linux/swap.h:#define KSWAPD_ZONE_BALANCE_GAP_RATIO 100


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
