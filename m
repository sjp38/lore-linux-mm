Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60CBC6B0033
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 21:34:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c195so13115992itb.5
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 18:34:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l191si1879739oig.433.2017.09.21.18.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 18:34:25 -0700 (PDT)
Message-ID: <1506044061.21121.70.camel@redhat.com>
Subject: Re: [PATCH 1/2] mm: avoid marking swap cached page as lazyfree
From: Rik van Riel <riel@redhat.com>
Date: Thu, 21 Sep 2017 21:34:21 -0400
In-Reply-To: <c7f1760cc75db5d129f22f69e900db153b80f8f1.1506024100.git.shli@fb.com>
References: <cover.1506024100.git.shli@fb.com>
	 <c7f1760cc75db5d129f22f69e900db153b80f8f1.1506024100.git.shli@fb.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org
Cc: Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2017-09-21 at 13:27 -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree
> (clear
> SwapBacked). There is no lock to prevent the page is added to swap
> cache
> between these two steps by page reclaim. If the page is added to swap
> cache, marking the page lazyfree will confuse page fault if the page
> is
> reclaimed and refault.
> 
> Reported-and-tested-y: Artem Savkov <asavkov@redhat.com>
> Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
> Signed-off-by: Shaohua Li <shli@fb.com>
> Cc: stable@vger.kernel.org
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
