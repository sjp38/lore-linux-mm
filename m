Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DB3966B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:19:32 -0400 (EDT)
Message-ID: <502115DB.105@redhat.com>
Date: Tue, 07 Aug 2012 09:19:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm: compaction: Update comment in try_to_compact_pages
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/07/2012 08:31 AM, Mel Gorman wrote:
> The comment about order applied when the check was
> order>  PAGE_ALLOC_COSTLY_ORDER which has not been the case since
> [c5a73c3d: thp: use compaction for all allocation orders]. Fixing
> the comment while I'm in the general area.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
