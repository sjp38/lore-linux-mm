Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 340B86B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:19:57 -0400 (EDT)
Date: Mon, 19 Aug 2013 16:05:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 5/7] mm: munlock: bypass per-cpu pvec for
 putback_lru_page
Message-ID: <20130819150542.GE23002@suse.de>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
 <1376915022-12741-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376915022-12741-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, J?rn Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Aug 19, 2013 at 02:23:40PM +0200, Vlastimil Babka wrote:
> After introducing batching by pagevecs into munlock_vma_range(), we can further
> improve performance by bypassing the copying into per-cpu pagevec and the
> get_page/put_page pair associated with that. Instead we perform LRU putback
> directly from our pagevec. However, this is possible only for single-mapped
> pages that are evictable after munlock. Unevictable pages require rechecking
> after putting on the unevictable list, so for those we fallback to
> putback_lru_page(), hich handles that.
> 
> After this patch, a 13% speedup was measured for munlocking a 56GB large memory
> area with THP disabled.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Jorn Engel <joern@logfs.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
