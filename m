Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B17446B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:35:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so291977375pge.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:35:40 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q13si3247498plk.173.2017.01.25.17.35.39
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 17:35:39 -0800 (PST)
Date: Thu, 26 Jan 2017 10:35:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/5] mm: vmscan: kick flushers when we encounter dirty
 pages on the LRU
Message-ID: <20170126013537.GB21211@bbox>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:38PM -0500, Johannes Weiner wrote:
> Memory pressure can put dirty pages at the end of the LRU without
> anybody running into dirty limits. Don't start writing individual
> pages from kswapd while the flushers might be asleep.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
