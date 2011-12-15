Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A9E836B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 18:36:21 -0500 (EST)
Message-ID: <4EEA8470.9040907@redhat.com>
Date: Thu, 15 Dec 2011 18:36:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/11] mm: vmscan: Do not OOM if aborting reclaim to start
 compaction
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> During direct reclaim it is possible that reclaim will be aborted so
> that compaction can be attempted to satisfy a high-order allocation. If
> this decision is made before any pages are reclaimed, it is possible
> that 0 is returned to the page allocator potentially triggering an
> OOM. This has not been observed but it is a possibility so this patch
> addresses it.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
