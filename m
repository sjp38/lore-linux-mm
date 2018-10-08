Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C35C6B000D
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 16:59:07 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id v132-v6so14003304ywb.15
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 13:59:07 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v71-v6si4116807ybg.309.2018.10.08.13.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 13:59:06 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] infiniband/mm: convert put_page() to
 put_user_page*()
References: <20181006024949.20691-1-jhubbard@nvidia.com>
 <20181006024949.20691-4-jhubbard@nvidia.com>
 <20181008194240.GA27639@ziepe.ca>
 <15d3daac-ba59-b1c9-873d-1876b58bde9d@nvidia.com>
 <20181008205602.GD27639@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b0f469c7-25dd-d86c-315d-149a9a64e231@nvidia.com>
Date: Mon, 8 Oct 2018 13:59:03 -0700
MIME-Version: 1.0
In-Reply-To: <20181008205602.GD27639@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>, Christian Benvenuti <benve@cisco.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>

On 10/8/18 1:56 PM, Jason Gunthorpe wrote:
> On Mon, Oct 08, 2018 at 01:37:35PM -0700, John Hubbard wrote:
>> On 10/8/18 12:42 PM, Jason Gunthorpe wrote:
>>> On Fri, Oct 05, 2018 at 07:49:49PM -0700, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>> [...]
>>>>  drivers/infiniband/core/umem.c              |  7 ++++---
>>>>  drivers/infiniband/core/umem_odp.c          |  2 +-
>>>>  drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
>>>>  drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
>>>>  drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
>>>>  drivers/infiniband/hw/qib/qib_user_sdma.c   |  8 ++++----
>>>>  drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
>>>>  7 files changed, 24 insertions(+), 28 deletions(-)
>>>
>>> I have no issues with this, do you want this series to go through the
>>> rdma tree? Otherwise:
>>>
>>> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
>>>
>>
>> The RDMA tree seems like a good path for this, yes, glad you suggested
>> that.
>>
>> I'll post a v4 with the comment fix and the recent reviewed-by's, which
>> should be ready for that.  It's based on today's linux.git tree at the 
>> moment, but let me know if I should re-apply it to the RDMA tree.
> 
> I'm unclear who needs to ack the MM sections for us to take it to
> RDMA?
> 
> Otherwise it is no problem..
> 

It needs Andrew Morton (+CC) and preferably also Michal Hocko (already on CC).

thanks,
-- 
John Hubbard
NVIDIA
