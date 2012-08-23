Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 0EBF56B0070
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:37:25 -0400 (EDT)
Message-ID: <50366A64.8030203@redhat.com>
Date: Thu, 23 Aug 2012 13:37:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] vmscan: Fix obsolete comment of balance_pgdat
References: <1345619717-5322-1-git-send-email-minchan@kernel.org> <1345619717-5322-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>

On 08/22/2012 03:15 AM, Minchan Kim wrote:
> This patch correct obsolete comment caused by [1] and [2].
>
> [1] 7ac6218, kswapd lockup fix
> [2] 32a4330, mm: prevent kswapd from freeing excessive amounts of lowmem
>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
