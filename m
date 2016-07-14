Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81E1A6B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:58:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so55840572wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:58:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v132si3074204wmd.83.2016.07.14.05.56.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 05:57:04 -0700 (PDT)
Subject: Re: [PATCH 33/34] mm, vmstat: print node-based stats in zoneinfo file
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-34-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <042cd67f-6502-978f-f8f5-3dcdaa487f90@suse.cz>
Date: Thu, 14 Jul 2016 14:56:38 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-34-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
> There are a number of stats that were previously accessible via zoneinfo
> that are now invisible. While it is possible to create a new file for the
> node stats, this may be missed by users. Instead this patch prints the
> stats under the first populated zone in /proc/zoneinfo.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
