Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFC86B0003
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 20:05:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o3-v6so18565421pll.7
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 17:05:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b13-v6si21524554plm.275.2018.10.08.17.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 17:05:27 -0700 (PDT)
Date: Mon, 8 Oct 2018 17:05:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/3] mm: get_user_pages: consolidate error handling
Message-Id: <20181008170525.62d1a910f7811d7c66a8c34c@linux-foundation.org>
In-Reply-To: <20181008211623.30796-2-jhubbard@nvidia.com>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
	<20181008211623.30796-2-jhubbard@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon,  8 Oct 2018 14:16:21 -0700 john.hubbard@gmail.com wrote:

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

Reviewed-by: Andrew Morton <akpm@linux-foundation.org>

`i' is a pretty crappy identifier as well, but we'll live.
