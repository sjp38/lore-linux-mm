Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 597886B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:48:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so55660708wmr.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:48:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si33449610wmg.137.2016.07.14.05.48.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 05:48:43 -0700 (PDT)
Subject: Re: [PATCH 26/34] mm, vmscan: avoid passing in remaining
 unnecessarily to prepare_kswapd_sleep
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-27-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <542815e6-f158-44e7-cf23-c6b5b20acee2@suse.cz>
Date: Thu, 14 Jul 2016 14:48:40 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-27-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
> As pointed out by Minchan Kim, the first call to prepare_kswapd_sleep
> always passes in 0 for remaining and the second call can trivially
> check the parameter in advance.
>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
