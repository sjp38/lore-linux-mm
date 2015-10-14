Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 891356B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 22:34:25 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so7961570pad.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:34:25 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id z5si9466547pbt.98.2015.10.13.19.34.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 19:34:24 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so39058866pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:34:24 -0700 (PDT)
Date: Tue, 13 Oct 2015 19:34:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2] mm, page_alloc: reserve pageblocks for high-order
 atomic allocations on demand -fix
In-Reply-To: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
Message-ID: <alpine.DEB.2.10.1510131934060.12718@chino.kir.corp.google.com>
References: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Oct 2015, yalin wang wrote:

> There is a redundant check and a memory leak introduced by a patch in
> mmotm. This patch removes an unlikely(order) check as we are sure order
> is not zero at the time. It also checks if a page is already allocated
> to avoid a memory leak.
> 
> This is a fix to the mmotm patch
> mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: David Rientjes <rientjes@google.com>

Cool find!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
