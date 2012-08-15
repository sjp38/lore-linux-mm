Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 23D856B006E
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 14:51:52 -0400 (EDT)
Message-ID: <502BEF53.80200@redhat.com>
Date: Wed, 15 Aug 2012 14:49:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/2] cma: remove __reclaim_pages
References: <1344934627-8473-1-git-send-email-minchan@kernel.org> <1344934627-8473-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1344934627-8473-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2012 04:57 AM, Minchan Kim wrote:
> Now cma reclaims too many pages by __reclaim_pages which says
> following as
>
>          * Reclaim enough pages to make sure that contiguous allocation
>          * will not starve the system.
>
> Starve? What does it starve the system? The function which allocate
> free page for migration target would wake up kswapd and do direct reclaim
> if needed during migration so system doesn't starve.
>
> Let remove __reclaim_pages and related function and fields.

Fair enough.

> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
