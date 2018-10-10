Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10AD66B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 14:35:54 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z14-v6so2981199ybp.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:35:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 15-v6si6102706ywj.222.2018.10.10.11.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 11:35:53 -0700 (PDT)
Subject: Re: [PATCH v5 2/3] mm: introduce put_user_page*(), placeholder
 versions
References: <20181010041134.14096-1-jhubbard@nvidia.com>
 <20181010041134.14096-3-jhubbard@nvidia.com>
 <20181010080326.GB11507@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <75681b69-2db6-bc46-efe3-48d029c9ec22@nvidia.com>
Date: Wed, 10 Oct 2018 11:35:51 -0700
MIME-Version: 1.0
In-Reply-To: <20181010080326.GB11507@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On 10/10/18 1:03 AM, Jan Kara wrote:
> On Tue 09-10-18 21:11:33, john.hubbard@gmail.com wrote:
>> +/*
>> + * put_user_pages() - for each page in the @pages array, release the page
>> + * using put_user_page().
>> + *
>> + * Please see the put_user_page() documentation for details.
>> + *
>> + * This is just like put_user_pages_dirty(), except that it invokes
>> + * set_page_dirty_lock(), instead of set_page_dirty().
> 
> This paragraph should be deleted. Other than that the patch looks good.
> 

Good catch. Fixed locally, and it will go up with the next spin.

thanks,
-- 
John Hubbard
NVIDIA
