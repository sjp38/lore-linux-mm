Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C27026B026C
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:03:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 31-v6so2726396edr.19
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:03:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q11-v6si6214251ejx.166.2018.10.10.01.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 01:03:27 -0700 (PDT)
Date: Wed, 10 Oct 2018 10:03:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20181010080326.GB11507@quack2.suse.cz>
References: <20181010041134.14096-1-jhubbard@nvidia.com>
 <20181010041134.14096-3-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010041134.14096-3-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Tue 09-10-18 21:11:33, john.hubbard@gmail.com wrote:
> +/*
> + * put_user_pages() - for each page in the @pages array, release the page
> + * using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * This is just like put_user_pages_dirty(), except that it invokes
> + * set_page_dirty_lock(), instead of set_page_dirty().

This paragraph should be deleted. Other than that the patch looks good.

								Honza

> + *
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + */
> +void put_user_pages(struct page **pages, unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++)
> +		put_user_page(pages[index]);
> +}
> +EXPORT_SYMBOL(put_user_pages);
> +
>  /*
>   * get_kernel_pages() - pin kernel pages in memory
>   * @kiov:	An array of struct kvec structures
> -- 
> 2.19.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
