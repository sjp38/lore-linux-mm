Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F25C36B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:59:08 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so38599212wjc.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:59:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s16si819786wmb.17.2017.01.26.01.59.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 01:59:07 -0800 (PST)
Date: Thu, 26 Jan 2017 09:57:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/5] mm: vmscan: kick flushers when we encounter dirty
 pages on the LRU
Message-ID: <20170126095745.ueigbrsop5vgmwzj@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:38PM -0500, Johannes Weiner wrote:
> Memory pressure can put dirty pages at the end of the LRU without
> anybody running into dirty limits. Don't start writing individual
> pages from kswapd while the flushers might be asleep.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I don't understand the motivation for checking the wb_reason name. Maybe
it was easier to eyeball while reading ftraces. The comment about the
flusher not doing its job could also be as simple as the writes took
place and clean pages were reclaimed before dirty_expire was reached.
Not impossible if there was a light writer combined with a heavy reader
or a large number of anonymous faults.

Anyway;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
