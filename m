Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1F4166B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:26:20 -0400 (EDT)
Message-ID: <50211778.3030709@redhat.com>
Date: Tue, 07 Aug 2012 09:26:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] mm: kswapd: Continue reclaiming for reclaim/compaction
 if the minimum number of pages have not been reclaimed
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/07/2012 08:31 AM, Mel Gorman wrote:
> When direct reclaim is running reclaim/compaction, there is a minimum
> number of pages it reclaims. As it must be under the low watermark to be
> in direct reclaim it has also woken kswapd to do some work. This patch
> has kswapd use the same logic as direct reclaim to reclaim a minimum
> number of pages so compaction can run later.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
