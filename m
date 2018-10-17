Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC3F96B0006
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:09:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so16333057edc.2
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:09:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31-v6si5543735edc.211.2018.10.17.04.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 04:09:54 -0700 (PDT)
Date: Wed, 17 Oct 2018 13:09:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181017110952.GN18839@dhcp22.suse.cz>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013230124.GB18822@dastard>
 <20181016085102.GB18918@quack2.suse.cz>
 <a9f1df2f-da9d-bf7b-b977-d3d3ca710776@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9f1df2f-da9d-bf7b-b977-d3d3ca710776@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Tue 16-10-18 18:48:23, John Hubbard wrote:
[...]
> It's hard to say exactly what the active/inactive/unevictable list should
> be when DMA is done and put_user_page*() is called, because we don't know
> if some device read, wrote, or ignored any of those pages. Although if 
> put_user_pages_dirty() is called, that's an argument for "active", at least.

Any reason to not use putback_lru_page?

Please note I haven't really got through your patches to have a wider
picture of the change so this is just hint for the LRU part of the
issue.
-- 
Michal Hocko
SUSE Labs
