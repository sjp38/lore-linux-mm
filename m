Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id A7A6F6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 19:24:22 -0400 (EDT)
Date: Wed, 8 Aug 2012 08:25:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/6] mm: compaction: Update comment in
 try_to_compact_pages
Message-ID: <20120807232552.GA4247@bbox>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344342677-5845-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 07, 2012 at 01:31:12PM +0100, Mel Gorman wrote:
> The comment about order applied when the check was
> order > PAGE_ALLOC_COSTLY_ORDER which has not been the case since
> [c5a73c3d: thp: use compaction for all allocation orders]. Fixing
> the comment while I'm in the general area.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
