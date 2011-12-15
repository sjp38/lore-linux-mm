Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 44DDA6B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 18:21:36 -0500 (EST)
Message-ID: <4EEA80F9.5040407@redhat.com>
Date: Thu, 15 Dec 2011 18:21:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/11] mm: vmscan: Check if we isolated a compound page
 during lumpy scan
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Properly take into account if we isolated a compound page during the
> lumpy scan in reclaim and skip over the tail pages when encountered.
> This corrects the values given to the tracepoint for number of lumpy
> pages isolated and will avoid breaking the loop early if compound
> pages smaller than the requested allocation size are requested.
>
> [mgorman@suse.de: Updated changelog]
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
