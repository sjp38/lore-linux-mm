Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9A2C66B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 08:47:18 -0400 (EDT)
Date: Fri, 21 Sep 2012 13:47:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] mm: remove free_page_mlock
Message-ID: <20120921124715.GD11157@csn.ul.ie>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 18, 2012 at 08:57:27PM -0700, Hugh Dickins wrote:
> We should not be seeing non-0 unevictable_pgs_mlockfreed any longer.
> So remove free_page_mlock() from the page freeing paths: __PG_MLOCKED
> is already in PAGE_FLAGS_CHECK_AT_FREE, so free_pages_check() will now
> be checking it, reporting "BUG: Bad page state" if it's ever found set.
> Comment UNEVICTABLE_MLOCKFREED and unevictable_pgs_mlockfreed always 0.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Ying Han <yinghan@google.com>

Like Johannes I think you should just drop the counter. I find it very
unlikely that there is a tool that depends on it existing because it's
very hard to draw any useful conclusions from its value unlikes like say
pgscan* or pgfault.

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks Hugh.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
