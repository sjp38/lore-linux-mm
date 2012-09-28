Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E55296B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:31:49 -0400 (EDT)
Date: Fri, 28 Sep 2012 11:31:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] thp: avoid VM_BUG_ON page_count(page) false positives in
 __collapse_huge_page_copy
Message-ID: <20120928153141.GA23734@cmpxchg.org>
References: <1348835731-27474-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348835731-27474-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>

On Fri, Sep 28, 2012 at 02:35:31PM +0200, Andrea Arcangeli wrote:
> Speculative cache pagecache lookups can elevate the refcount from
> under us, so avoid the false positive. If the refcount is < 2 we'll be
> notified by a VM_BUG_ON in put_page_testzero as there are two
> put_page(src_page) in a row before returning from this function.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Much better, thank you.

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
