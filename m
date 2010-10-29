Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DFFD56B0151
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 19:20:11 -0400 (EDT)
Date: Fri, 29 Oct 2010 16:19:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix ext2 and ext4 buffer-head accounting.
Message-Id: <20101029161911.046abe8a.akpm@linux-foundation.org>
In-Reply-To: <1288199797-22541-1-git-send-email-yinghan@google.com>
References: <1288199797-22541-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Nick Piggin <npiggin@suse.de>, Paul Turner <pjt@google.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Oct 2010 10:16:37 -0700
Ying Han <yinghan@google.com> wrote:

> Pages pinned to block group_descriptors in the super_block are non-reclaimable.
> Those pages are showed up as file-backed in meminfo which confuse user program
> issuing too many drop_caches/ttfp when this memory will never be freed.
> 
> The change has us not account for the file system descriptors by taking the pages
> off LRU and decrementing the NR_FILE_PAGES counter. The pages are putting back when
> the filesystem is being unmounted.

Well, it's not just ext2 and ext4.

Is this the simplest way of solving the problem?  This is just pinned
pagecache.  We already have way of handling pinned pagecache (eg,
mlocked pages).  Can we reuse those mechanisms, perhaps after suitable
generalisation?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
