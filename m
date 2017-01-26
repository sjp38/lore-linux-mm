Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDAA6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:27:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so291747987pge.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:27:17 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m124si1075206pgm.123.2017.01.25.17.27.15
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 17:27:16 -0800 (PST)
Date: Thu, 26 Jan 2017 10:27:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm: vmscan: scan dirty pages even in laptop mode
Message-ID: <20170126012713.GA21211@bbox>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:37PM -0500, Johannes Weiner wrote:
> We have an elaborate dirty/writeback throttling mechanism inside the
> reclaim scanner, but for that to work the pages have to go through
> shrink_page_list() and get counted for what they are. Otherwise, we
> mess up the LRU order and don't match reclaim speed to writeback.
> 
> Especially during deactivation, there is never a reason to skip dirty
> pages; nothing is even trying to write them out from there. Don't mess
> up the LRU order for nothing, shuffle these pages along.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
