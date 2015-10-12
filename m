Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4B68F6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 09:52:58 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so151254381wic.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:52:57 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id p4si16110150wia.27.2015.10.12.06.52.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 06:52:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 7DBF999022
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 13:52:56 +0000 (UTC)
Date: Mon, 12 Oct 2015 14:52:50 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] mm: fix a BUG, the page is allocated 2 times
Message-ID: <20151012135250.GA3625@techsingularity.net>
References: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 12, 2015 at 10:40:06AM +0800, yalin wang wrote:
> Remove unlikely(order), because we are sure order is not zero if
> code reach here, also add if (page == NULL), only allocate page again if
> __rmqueue_smallest() failed or alloc_flags & ALLOC_HARDER == 0
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Thanks very much for catching this!

Acked-by: Mel Gorman <mgorman@techsingularity.net>

With your current subject and changelog, there is a small risk that Andrew
will miss this or not see it for some time. Would you mind resending the
patch with a changelog similar to this please? It spells out that it is
a fix to an mmotm patch so it'll be obvious where it should be inserted
before merging to mainline.

From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] mm, page_alloc: reserve pageblocks for high-order atomic allocations on demand -fix

There is a redundant check and a memory leak introduced by a patch in
mmotm. This patch removes an unlikely(order) check as we are sure order
is not zero at the time. It also checks if a page is already allocated
to avoid a memory leak.

This is a fix to the mmotm patch
mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
