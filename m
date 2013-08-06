Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6CA966B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 09:23:29 -0400 (EDT)
Date: Tue, 6 Aug 2013 09:23:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/9] mm: compaction: don't require high order pages below
 min wmark
Message-ID: <20130806132321.GH1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-6-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:32PM +0200, Andrea Arcangeli wrote:
> The min wmark should be satisfied with just 1 hugepage. And the other
> wmarks should be adjusted accordingly. We need to succeed the low
> wmark check if there's some significant amount of 0 order pages, but
> we don't need plenty of high order pages because the PF_MEMALLOC paths
> don't require those. Creating a ton of high order pages that cannot be
> allocated by the high order allocation paths (no PF_MEMALLOC) is quite
> wasteful because they can be splitted in lower order pages before
> anybody has a chance to allocate them.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
