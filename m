Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 67D2C6B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 23:35:42 -0500 (EST)
Message-ID: <4EEACA96.6020200@redhat.com>
Date: Thu, 15 Dec 2011 23:35:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/11] mm: vmscan: When reclaiming for compaction, ensure
 there are sufficient free pages available
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> In commit [e0887c19: vmscan: limit direct reclaim for higher order
> allocations], Rik noted that reclaim was too aggressive when THP was
> enabled. In his initial patch he used the number of free pages to
> decide if reclaim should abort for compaction. My feedback was that
> reclaim and compaction should be using the same logic when deciding if
> reclaim should be aborted.
>
> Unfortunately, this had the effect of reducing THP success rates when
> the workload included something like streaming reads that continually
> allocated pages. The window during which compaction could run and return
> a THP was too small.
>
> This patch combines Rik's two patches together. compaction_suitable()
> is still used to decide if reclaim should be aborted to allow
> compaction is used. However, it will also ensure that there is a
> reasonable buffer of free pages available. This improves upon the
> THP allocation success rates but bounds the number of pages that are
> freed for compaction.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
