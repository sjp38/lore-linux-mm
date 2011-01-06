Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EFBD86B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 04:57:11 -0500 (EST)
Date: Thu, 6 Jan 2011 09:56:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 3/5] tlbfs: Remove unnecessary page release
Message-ID: <20110106095647.GC29257@csn.ul.ie>
References: <cover.1292604745.git.minchan.kim@gmail.com> <08549e97645f7d6c2bcc5c760a24fde56dfed513.1292604745.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <08549e97645f7d6c2bcc5c760a24fde56dfed513.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2010 at 02:13:38AM +0900, Minchan Kim wrote:
> This patch series changes remove_from_page_cache's page ref counting
> rule. page cache ref count is decreased in remove_from_page_cache.
> So we don't need call again in caller context.
> 
> Cc: William Irwin <wli@holomorphy.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Other than the subject calling hugetlbfs tlbfs, I did not see any problem
with this assuming the first patch of the series is also applied.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
