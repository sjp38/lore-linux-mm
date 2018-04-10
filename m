Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B33C26B0062
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:07:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d37so8069222wrd.21
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:07:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j2si965167edf.459.2018.04.10.06.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 06:07:02 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:08:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] page cache: Mask off unwanted GFP flags
Message-ID: <20180410130830.GB7010@cmpxchg.org>
References: <20180410125351.15837-1-willy@infradead.org>
 <20180410125351.15837-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410125351.15837-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, Apr 10, 2018 at 05:53:51AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The page cache has used the mapping's GFP flags for allocating
> radix tree nodes for a long time.  It took care to always mask off the
> __GFP_HIGHMEM flag, and masked off other flags in other paths, but the
> __GFP_ZERO flag was still able to sneak through.  The __GFP_DMA and
> __GFP_DMA32 flags would also have been able to sneak through if they
> were ever used.  Fix them all by using GFP_RECLAIM_MASK at the innermost
> location, and remove it from earlier in the callchain.

Could you please mention the nullptr crash here, maybe even in the
patch subject? That makes it much easier to find this patch when you
run into that bug or when evaluating backport candidates.

Other than that,

> Fixes: 19f99cee206c ("f2fs: add core inode operations")
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: stable@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
