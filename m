Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7DA6B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:42:40 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id wu1so209042298obb.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:42:40 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g131si1344446iof.190.2016.07.15.08.42.38
        for <linux-mm@kvack.org>;
        Fri, 15 Jul 2016 08:42:39 -0700 (PDT)
Date: Sat, 16 Jul 2016 00:42:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, vmscan: make shrink_node decisions more
 node-centric -fix
Message-ID: <20160715154239.GB8644@bbox>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468588165-12461-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:21PM +0100, Mel Gorman wrote:
> The patch "mm, vmscan: make shrink_node decisions more node-centric"
> checks whether compaction is suitable on empty nodes. This is expensive
> rather than wrong but is worth fixing.
> 
> This is a fix to the mmotm patch
> mm-vmscan-make-shrink_node-decisions-more-node-centric.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
