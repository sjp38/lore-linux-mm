Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8936B0005
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 17:20:00 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id c6-v6so8287738ybm.10
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 14:20:00 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j9-v6si1922517ywg.111.2018.10.13.14.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 14:20:00 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <005bc69b-ffa8-ccb4-db0b-3f4c52a54745@nvidia.com>
Date: Sat, 13 Oct 2018 14:19:57 -0700
MIME-Version: 1.0
In-Reply-To: <20181013164740.GA6593@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/13/18 9:47 AM, Christoph Hellwig wrote:
> On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
>> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
>> unceremoniously rips the pages out of the LRU, as a prerequisite to using
>> either of the page->dma_pinned_* fields. 
>>
>> The idea is that LRU is not especially useful for this situation anyway,
>> so we'll just make it one or the other: either a page is dma-pinned, and
>> just hanging out doing RDMA most likely (and LRU is less meaningful during that
>> time), or it's possibly on an LRU list.
> 
> Have you done any benchmarking what this does to direct I/O performance,
> especially for small I/O directly to a (fast) block device?

Not yet. I can go do that now. If you have any particular test suites, benchmarks,
or just programs to recommend, please let me know. So far, I see

   tools/testing/selftests/vm/gup_benchmark.c


-- 
thanks,
John Hubbard
NVIDIA
 
