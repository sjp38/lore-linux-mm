Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 88E7B6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:02:35 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:48:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 1/7] mm: putback_lru_page: remove unnecessary call to
 page_lru_base_type()
Message-ID: <20130819144819.GA23002@suse.de>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
 <1376915022-12741-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376915022-12741-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, J?rn Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Aug 19, 2013 at 02:23:36PM +0200, Vlastimil Babka wrote:
> In putback_lru_page() since commit c53954a092 (""mm: remove lru parameter from
> __lru_cache_add and lru_cache_add_lru") it is no longer needed to determine lru
> list via page_lru_base_type().
> 
> This patch replaces it with simple flag is_unevictable which says that the page
> was put on the inevictable list. This is the only information that matters in
> subsequent tests.
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
