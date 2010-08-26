Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C3B046B01F2
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:23:48 -0400 (EDT)
Received: by pvc30 with SMTP id 30so897021pvc.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:23:45 -0700 (PDT)
Date: Fri, 27 Aug 2010 02:23:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/3] writeback: Account for time spent congestion_waited
Message-ID: <20100826172338.GB6873@barrios-desktop>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <1282835656-5638-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282835656-5638-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 04:14:14PM +0100, Mel Gorman wrote:
> There is strong evidence to indicate a lot of time is being spent in
> congestion_wait(), some of it unnecessarily. This patch adds a
> tracepoint for congestion_wait to record when congestion_wait() occurred
> and how long was spent.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I think that's enough to add tracepoint until solving this issue at least.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
