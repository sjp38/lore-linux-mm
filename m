Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 9A3C06B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:22:00 -0400 (EDT)
Date: Mon, 19 Aug 2013 16:07:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 6/7] mm: munlock: remove redundant get_page/put_page
 pair on the fast path
Message-ID: <20130819150745.GF23002@suse.de>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
 <1376915022-12741-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376915022-12741-7-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, J?rn Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Aug 19, 2013 at 02:23:41PM +0200, Vlastimil Babka wrote:
> The performance of the fast path in munlock_vma_range() can be further improved
> by avoiding atomic ops of a redundant get_page()/put_page() pair.
> 
> When calling get_page() during page isolation, we already have the pin from
> follow_page_mask(). This pin will be then returned by __pagevec_lru_add(),
> after which we do not reference the pages anymore.
> 
> After this patch, an 8% speedup was measured for munlocking a 56GB large memory
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
