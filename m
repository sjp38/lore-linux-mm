Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B17216B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 13:21:42 -0400 (EDT)
Date: Wed, 19 Sep 2012 13:21:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] mm: remove free_page_mlock
Message-ID: <20120919172136.GS1560@cmpxchg.org>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 18, 2012 at 08:57:27PM -0700, Hugh Dickins wrote:
> We should not be seeing non-0 unevictable_pgs_mlockfreed any longer.
> So remove free_page_mlock() from the page freeing paths: __PG_MLOCKED
> is already in PAGE_FLAGS_CHECK_AT_FREE, so free_pages_check() will now
> be checking it, reporting "BUG: Bad page state" if it's ever found set.
> Comment UNEVICTABLE_MLOCKFREED and unevictable_pgs_mlockfreed always 0.

I would have just removed it because I don't see too many users
relying on it being there.  But I'm fine with keeping it for now.

> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Ying Han <yinghan@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
