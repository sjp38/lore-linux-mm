Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 416C06B00EE
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 10:20:26 -0400 (EDT)
Date: Wed, 7 Aug 2013 15:20:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 2/3] mm: page_alloc: rearrange watermark checking in
 get_page_from_freelist
Message-ID: <20130807142021.GP2296@suse.de>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375457846-21521-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 02, 2013 at 11:37:25AM -0400, Johannes Weiner wrote:
> Allocations that do not have to respect the watermarks are rare
> high-priority events.  Reorder the code such that per-zone dirty
> limits and future checks important only to regular page allocations
> are ignored in these extraordinary situations.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
