Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA5746B0032
	for <linux-mm@kvack.org>; Sun,  9 Oct 2011 04:04:45 -0400 (EDT)
Received: by pzk4 with SMTP id 4so14954255pzk.6
        for <linux-mm@kvack.org>; Sun, 09 Oct 2011 01:04:43 -0700 (PDT)
Date: Sun, 9 Oct 2011 17:04:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/2] mm: Abort reclaim/compaction if compaction can
 proceed
Message-ID: <20111009080434.GD23003@barrios-desktop>
References: <1318000643-27996-1-git-send-email-mgorman@suse.de>
 <1318000643-27996-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318000643-27996-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 07, 2011 at 04:17:23PM +0100, Mel Gorman wrote:
> If compaction can proceed, shrink_zones() stops doing any work but
> the callers still shrink_slab(), raises the priority and potentially
> sleeps.  This patch aborts direct reclaim/compaction entirely if
> compaction can proceed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
