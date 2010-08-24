Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8D7046B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:07:32 -0400 (EDT)
Date: Tue, 24 Aug 2010 12:09:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] compaction: fix COMPACTPAGEFAILED counting
In-Reply-To: <1282664620-4539-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1008241207130.3695@router.home>
References: <1282664620-4539-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010, Minchan Kim wrote:

> This patch makes new rule for caller of migrate_pages to call putback_lru_pages.
> So caller need to clean up the lists so it has a chance to postprocess the pages.
> [suggested by Christoph Lameter]

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
