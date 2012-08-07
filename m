Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id BE1196B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 10:45:31 -0400 (EDT)
Message-ID: <50212A05.2070503@redhat.com>
Date: Tue, 07 Aug 2012 10:45:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: have order > 0 compaction start near a pageblock
 with free pages
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/07/2012 08:31 AM, Mel Gorman wrote:
> commit [7db8889a: mm: have order>  0 compaction start off where it left]
> introduced a caching mechanism to reduce the amount work the free page
> scanner does in compaction. However, it has a problem. Consider two process
> simultaneously scanning free pages
>
> 				    			C
> Process A		M     S     			F
> 		|---------------------------------------|
> Process B		M 	FS

Argh. Good spotting.

> This is not optimal and it can still race but the compact_cached_free_pfn
> will be pointing to or very near a pageblock with free pages.

Agreed on the "not optimal", but I also cannot think of a better
idea right now. Getting this fixed for 3.6 is important, we can
think of future optimizations in San Diego.

> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
