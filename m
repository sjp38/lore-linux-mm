Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 294176B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:59:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id qh10so4328992pac.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:59:09 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id tr8si1950868pab.170.2016.07.18.16.59.07
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 16:59:08 -0700 (PDT)
Date: Tue, 19 Jul 2016 08:59:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] mm, vmstat: remove zone and node double accounting
 by approximating retries -fix
Message-ID: <20160718235919.GC9161@bbox>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
 <1468853426-12858-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468853426-12858-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:26PM +0100, Mel Gorman wrote:
> As pointed out by Vlastimil, the atomic_add() functions are already assumed
> to be able to handle negative numbers. The atomic_sub handling was wrong
> anyway but this patch fixes it unconditionally.
> 
> This is a fix to the mmotm patch
> mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
