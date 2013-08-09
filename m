Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id BBBF46B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 14:46:20 -0400 (EDT)
Message-ID: <520538D3.9000705@surriel.com>
Date: Fri, 09 Aug 2013 14:45:39 -0400
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org> <20130807145828.GQ2296@suse.de> <20130807153743.GH715@cmpxchg.org> <20130808041623.GL1845@cmpxchg.org>
In-Reply-To: <20130808041623.GL1845@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/08/2013 12:16 AM, Johannes Weiner wrote:

> Patch on top of mmotm:

Yes, please!

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching
>
> Avoid dirtying the same cache line with every single page allocation
> by making the fair per-zone allocation batch a vmstat item, which will
> turn it into batched percpu counters on SMP.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
