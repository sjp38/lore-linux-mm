Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED576B0007
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 12:49:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 84-v6so11231514pgc.13
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 09:49:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f23-v6si3903151pfn.85.2018.10.08.09.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 09:49:36 -0700 (PDT)
Date: Mon, 8 Oct 2018 18:49:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 3/3] infiniband/mm: convert put_page() to
 put_user_page*()
Message-ID: <20181008164934.GB11150@quack2.suse.cz>
References: <20181006024949.20691-1-jhubbard@nvidia.com>
 <20181006024949.20691-4-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181006024949.20691-4-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On Fri 05-10-18 19:49:49, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For code that retains pages via get_user_pages*(),
> release those pages via the new put_user_page(), or
> put_user_pages*(), instead of put_page()
> 
> This prepares for eventually fixing the problem described
> in [1], and is following a plan listed in [2], [3], [4].
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>     Proposed steps for fixing get_user_pages() + DMA problems.
> 
> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
>     Bounce buffers (otherwise [2] is not really viable).
> 
> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
>     Follow-up discussions.
> 
> CC: Doug Ledford <dledford@redhat.com>
> CC: Jason Gunthorpe <jgg@ziepe.ca>
> CC: Mike Marciniszyn <mike.marciniszyn@intel.com>
> CC: Dennis Dalessandro <dennis.dalessandro@intel.com>
> CC: Christian Benvenuti <benve@cisco.com>
> 
> CC: linux-rdma@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
