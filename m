Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26A946B0254
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:08:54 -0400 (EDT)
Received: by wieq12 with SMTP id q12so21667311wie.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:08:53 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id q13si21810422wiv.18.2015.10.13.02.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 02:08:53 -0700 (PDT)
Received: by wijq8 with SMTP id q8so21578080wij.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:08:52 -0700 (PDT)
Date: Tue, 13 Oct 2015 12:08:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm, page_alloc: reserve pageblocks for high-order
 atomic allocations on demand -fix
Message-ID: <20151013090850.GA11942@node>
References: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 13, 2015 at 09:42:24AM +0800, yalin wang wrote:
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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
