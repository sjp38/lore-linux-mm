Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C22696B0005
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 12:47:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r72-v6so10966093pfj.3
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 09:47:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r144-v6si5851962pfr.100.2018.10.13.09.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 13 Oct 2018 09:47:48 -0700 (PDT)
Date: Sat, 13 Oct 2018 09:47:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181013164740.GA6593@infradead.org>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
> unceremoniously rips the pages out of the LRU, as a prerequisite to using
> either of the page->dma_pinned_* fields. 
> 
> The idea is that LRU is not especially useful for this situation anyway,
> so we'll just make it one or the other: either a page is dma-pinned, and
> just hanging out doing RDMA most likely (and LRU is less meaningful during that
> time), or it's possibly on an LRU list.

Have you done any benchmarking what this does to direct I/O performance,
especially for small I/O directly to a (fast) block device?
