Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E73216B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:28:50 -0400 (EDT)
Received: by pxi5 with SMTP id 5so1628690pxi.14
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 08:28:49 -0700 (PDT)
Date: Wed, 8 Sep 2010 00:28:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use
 lock_page() instead trylock_page()
Message-ID: <20100907152840.GD4620@barrios-desktop>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-6-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1283770053-18833-6-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 11:47:28AM +0100, Mel Gorman wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> With synchrounous lumpy reclaim, there is no reason to give up to reclaim
> pages even if page is locked. This patch uses lock_page() instead of
> trylock_page() in this case.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
