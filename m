Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8A6306B009E
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 18:06:59 -0500 (EST)
Date: Mon, 4 Feb 2013 15:06:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high
 memory
Message-Id: <20130204150657.6d05f76a.akpm@linux-foundation.org>
In-Reply-To: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com

On Mon, 04 Feb 2013 11:27:05 +0100
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> The total number of low memory pages is determined as
> totalram_pages - totalhigh_pages, so without this patch all CMA
> pageblocks placed in highmem were accounted to low memory.

What are the end-user-visible effects of this bug?

(This information is needed so that others can make patch-scheduling
decisions and should be included in all bugfix changelogs unless it is
obvious).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
