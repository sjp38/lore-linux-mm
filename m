Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6656B046E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 12:40:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i10so4302641wrb.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 09:40:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n82si1431147wmf.7.2017.02.16.09.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 09:40:07 -0800 (PST)
Date: Thu, 16 Feb 2017 12:39:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 1/7] mm: don't assume anonymous pages have SwapBacked
 flag
Message-ID: <20170216173958.GA20791@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <62e817d1d7fbee415ded0ac76233cb1329ffe06f.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62e817d1d7fbee415ded0ac76233cb1329ffe06f.1487100204.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Tue, Feb 14, 2017 at 11:36:07AM -0800, Shaohua Li wrote:
> There are a few places the code assumes anonymous pages should have
> SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
> going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
> for them. The assumption doesn't hold any more, so fix them.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
