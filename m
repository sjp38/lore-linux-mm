Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 603F36B006C
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 12:46:31 -0400 (EDT)
Date: Wed, 19 Sep 2012 12:46:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: remove vma arg from page_evictable
Message-ID: <20120919164625.GQ1560@cmpxchg.org>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182052030.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209182052030.11632@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 18, 2012 at 08:53:45PM -0700, Hugh Dickins wrote:
> page_evictable(page, vma) is an irritant: almost all its callers pass
> NULL for vma.  Remove the vma arg and use mlocked_vma_newpage(vma, page)
> explicitly in the couple of places it's needed.  But in those places we
> don't even need page_evictable() itself!  They're dealing with a freshly
> allocated anonymous page, which has no "mapping" and cannot be mlocked yet.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Ying Han <yinghan@google.com>

Much better.  With documentation updates and everything, thank you!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
