Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51F9B6B0003
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 11:53:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t8-v6so17570411plo.4
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 08:53:26 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i10-v6si18059593pgc.420.2018.10.08.08.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 08:53:25 -0700 (PDT)
Subject: Re: [PATCH v3 0/3] get_user_pages*() and RDMA: first steps
References: <20181006024949.20691-1-jhubbard@nvidia.com>
From: Dennis Dalessandro <dennis.dalessandro@intel.com>
Message-ID: <8973680e-4391-48cf-e979-1e9a10be0968@intel.com>
Date: Mon, 8 Oct 2018 11:50:50 -0400
MIME-Version: 1.0
In-Reply-To: <20181006024949.20691-1-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On 10/5/2018 10:49 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Changes since v2:
> 
> -- Absorbed more dirty page handling logic into the put_user_page*(), and
>     handled some page releasing loops in infiniband more thoroughly, as per
>     Jason Gunthorpe's feedback.
> 
> -- Fixed a bug in the put_user_pages*() routines' loops (thanks to
>     Ralph Campbell for spotting it).
> 
> Changes since v1:
> 
> -- Renamed release_user_pages*() to put_user_pages*(), from Jan's feedback.
> 
> -- Removed the goldfish.c changes, and instead, only included a single
>     user (infiniband) of the new functions. That is because goldfish.c no
>     longer has a name collision (it has a release_user_pages() routine), and
>     also because infiniband exercises both the put_user_page() and
>     put_user_pages*() paths.
> 
> -- Updated links to discussions and plans, so as to be sure to include
>     bounce buffers, thanks to Jerome's feedback.
> 
> Also:
> 
> -- Dennis, thanks for your earlier review, and I have not yet added your
>     Reviewed-by tag, because this revision changes the things that you had
>     previously reviewed, thus potentially requiring another look.

This spin looks fine to me.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
