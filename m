Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EF9B06B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:52:18 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id l6so57256295wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:52:18 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id yu7si2320772wjc.184.2016.04.06.02.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 02:52:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 7D3FB1C1D3C
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:52:17 +0100 (IST)
Date: Wed, 6 Apr 2016 10:52:15 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/10] mm: use __SetPageSwapBacked and dont
 ClearPageSwapBacked
Message-ID: <20160406095136.GC4773@techsingularity.net>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051342080.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051342080.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:44:16PM -0700, Hugh Dickins wrote:
> v3.16 commit 07a427884348 ("mm: shmem: avoid atomic operation during
> shmem_getpage_gfp") rightly replaced one instance of SetPageSwapBacked
> by __SetPageSwapBacked, pointing out that the newly allocated page is
> not yet visible to other users (except speculative get_page_unless_zero-
> ers, who may not update page flags before their further checks).
> 
> That was part of a series in which Mel was focused on tmpfs profiles:
> but almost all SetPageSwapBacked uses can be so optimized, with the same
> justification.  Remove ClearPageSwapBacked from __read_swap_cache_async()
> error path: it's not an error to free a page with PG_swapbacked set.
> 
> Follow a convention of __SetPageLocked, __SetPageSwapBacked instead of
> doing it differently in different places; but that's for tidiness - if
> the ordering actually mattered, we should not be using the __variants.
> 
> There's probably scope for further __SetPageFlags in other places,
> but SwapBacked is the one I'm interested in at the moment.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> Sorry, Mel did give
> a year ago, but the kernel has moved on since then,

Still looks good to me so

Reviewed-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
