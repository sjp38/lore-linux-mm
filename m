Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32B446B000D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:11:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id ba5-v6so21039767plb.17
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:11:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u81-v6si24219022pfi.175.2018.10.19.01.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 01:11:18 -0700 (PDT)
Date: Fri, 19 Oct 2018 10:11:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181019081115.GM18839@dhcp22.suse.cz>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013230124.GB18822@dastard>
 <20181016085102.GB18918@quack2.suse.cz>
 <a9f1df2f-da9d-bf7b-b977-d3d3ca710776@nvidia.com>
 <20181017110952.GN18839@dhcp22.suse.cz>
 <2367ff26-809c-da94-a8f0-e921bdc4862a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2367ff26-809c-da94-a8f0-e921bdc4862a@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Wed 17-10-18 17:03:03, John Hubbard wrote:
> On 10/17/18 4:09 AM, Michal Hocko wrote:
> > On Tue 16-10-18 18:48:23, John Hubbard wrote:
> > [...]
> >> It's hard to say exactly what the active/inactive/unevictable list should
> >> be when DMA is done and put_user_page*() is called, because we don't know
> >> if some device read, wrote, or ignored any of those pages. Although if 
> >> put_user_pages_dirty() is called, that's an argument for "active", at least.
> > 
> > Any reason to not use putback_lru_page?
> 
> That does help with which LRU to use. I guess I'd still need to track whether
> a page was on an LRU when get_user_pages() was called, because it seems
> that that is not necessarily always the case. And putback_lru_page() definitely
> wants to deal with a page that *was* previously on an LRU.

Well, if you ever g-u-p pages which are never going to go to LRU then
sure (e.g. hugetlb pages).
-- 
Michal Hocko
SUSE Labs
