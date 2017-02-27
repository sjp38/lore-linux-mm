Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEA2E6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:27:05 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so20248574wrc.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:27:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 96si7031939wrk.134.2017.02.27.09.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 09:27:04 -0800 (PST)
Date: Mon, 27 Feb 2017 12:21:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170227172112.GC20423@cmpxchg.org>
References: <cover.1487965799.git.shli@fb.com>
 <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 01:31:47PM -0800, Shaohua Li wrote:
> When memory pressure is high, we free MADV_FREE pages. If the pages are
> not dirty in pte, the pages could be freed immediately. Otherwise we
> can't reclaim them. We put the pages back to anonumous LRU list (by
> setting SwapBacked flag) and the pages will be reclaimed in normal
> swapout way.
> 
> We use normal page reclaim policy. Since MADV_FREE pages are put into
> inactive file list, such pages and inactive file pages are reclaimed
> according to their age. This is expected, because we don't want to
> reclaim too many MADV_FREE pages before used once pages.
> 
> Based on Minchan's original patch
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

FWIW, I agree with Minchan that this could be folded into the previous
patch and would be a little neater. But I don't feel strongly in this
case since I didn't have any trouble reviewing the patches like this -
void mark_page_lazyfree(struct page *) is an easy API to remember.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
