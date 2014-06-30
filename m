Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9126B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 10:32:46 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so8355329pde.31
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 07:32:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id vq10si23352843pab.121.2014.06.30.07.32.45
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 07:32:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1403366036-10169-3-git-send-email-chris@chris-wilson.co.uk>
References: <20140619135944.20837E00A3@blue.fi.intel.com>
 <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
 <1403366036-10169-3-git-send-email-chris@chris-wilson.co.uk>
Subject: RE: [PATCH 3/4] mm: Export remap_io_mapping()
Content-Transfer-Encoding: 7bit
Message-Id: <20140630143240.25B87E00A3@blue.fi.intel.com>
Date: Mon, 30 Jun 2014 17:32:40 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

Chris Wilson wrote:
> This is similar to remap_pfn_range(), and uses the recently refactor
> code to do the page table walking. The key difference is that is back
> propagates its error as this is required for use from within a pagefault
> handler. The other difference, is that it combine the page protection
> from io-mapping, which is known from when the io-mapping is created,
> with the per-vma page protection flags. This avoids having to walk the
> entire system description to rediscover the special page protection
> established for the io-mapping.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>

Looks okay to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
