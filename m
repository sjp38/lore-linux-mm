Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7E4A6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 23:29:22 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c126so128650415ith.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:29:22 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q72si1469468itc.67.2016.07.28.20.29.21
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 20:29:22 -0700 (PDT)
Date: Fri, 29 Jul 2016 12:30:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: move swap-in anonymous page into active list
Message-ID: <20160729033007.GA17905@bbox>
References: <1469762740-17860-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
In-Reply-To: <1469762740-17860-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Fri, Jul 29, 2016 at 12:25:40PM +0900, Minchan Kim wrote:
> Every swap-in anonymous page starts from inactive lru list's head.
> It should be activated unconditionally when VM decide to reclaim
> because page table entry for the page always usually has marked
> accessed bit. Thus, their window size for getting a new referece
> is 2 * NR_inactive + NR_active while others is NR_active + NR_active.

                                                 NR_inactive

typo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
