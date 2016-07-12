Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 782D96B0260
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:18:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so17006131lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:18:10 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q126si11249947wme.10.2016.07.12.12.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 12:18:09 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:18:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 33/34] mm, vmstat: print node-based stats in zoneinfo file
Message-ID: <20160712191802.GD8629@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-34-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-34-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:09AM +0100, Mel Gorman wrote:
> There are a number of stats that were previously accessible via zoneinfo
> that are now invisible. While it is possible to create a new file for the
> node stats, this may be missed by users. Instead this patch prints the
> stats under the first populated zone in /proc/zoneinfo.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

I had no idea we could make /proc/zoneinfo any worse!

But it'll work, I guess.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
