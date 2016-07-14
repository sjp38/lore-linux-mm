Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 550986B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 06:09:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so53307355wma.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 03:09:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si1014018lfd.367.2016.07.14.03.09.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 03:09:21 -0700 (PDT)
Subject: Re: [PATCH 24/34] mm, vmscan: avoid passing in classzone_idx
 unnecessarily to shrink_node
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-25-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad44d31b-7d98-14e5-2bcc-017a209746be@suse.cz>
Date: Thu, 14 Jul 2016 12:09:19 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-25-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
> shrink_node receives all information it needs about classzone_idx
> from sc->reclaim_idx so remove the aliases.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
