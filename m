Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E08C16B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 02:30:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x17-v6so1162243pln.4
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 23:30:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2-v6sor179640plq.31.2018.10.11.23.30.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 23:30:40 -0700 (PDT)
Date: Fri, 12 Oct 2018 17:30:34 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 1/6] mm: get_user_pages: consolidate error handling
Message-ID: <20181012063034.GI8537@350D>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012060014.10242-2-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Thu, Oct 11, 2018 at 11:00:09PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> An upcoming patch requires a way to operate on each page that
> any of the get_user_pages_*() variants returns.
> 
> In preparation for that, consolidate the error handling for
> __get_user_pages(). This provides a single location (the "out:" label)
> for operating on the collected set of pages that are about to be returned.
> 
> As long every use of the "ret" variable is being edited, rename
> "ret" --> "err", so that its name matches its true role.
> This also gets rid of two shadowed variable declarations, as a
> tiny beneficial a side effect.
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---

Looks good, might not be needed but
Reviewed-by: Balbir Singh <bsingharora@gmail.com>
