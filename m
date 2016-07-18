Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0F876B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:54:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p64so5049189pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:54:03 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id tf1si2212168pab.230.2016.07.18.16.54.01
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 16:54:03 -0700 (PDT)
Date: Tue, 19 Jul 2016 08:54:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: Remove redundant check in shrink_zones()
Message-ID: <20160718235414.GA9161@bbox>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
 <1468853426-12858-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468853426-12858-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:24PM +0100, Mel Gorman wrote:
> As pointed out by Minchan Kim, shrink_zones() checks for populated
> zones in a zonelist but a zonelist can never contain unpopulated
> zones. While it's not related to the node-lru series, it can be
> cleaned up now.
> 
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
