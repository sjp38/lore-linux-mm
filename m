Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 912586B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 19:33:23 -0400 (EDT)
Date: Fri, 10 Aug 2012 08:35:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm: compaction: Capture a suitable high-order page
 immediately when it is made available
Message-ID: <20120809233503.GE21033@bbox>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <1344520165-24419-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344520165-24419-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 02:49:23PM +0100, Mel Gorman wrote:
> While compaction is migrating pages to free up large contiguous blocks for
> allocation it races with other allocation requests that may steal these
> blocks or break them up. This patch alters direct compaction to capture a
> suitable free page as soon as it becomes available to reduce this race. It
> uses similar logic to split_free_page() to ensure that watermarks are
> still obeyed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
