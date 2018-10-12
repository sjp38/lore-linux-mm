Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 100D96B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:45:08 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id n8-v6so6248204yba.13
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:45:08 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id m6-v6si915879ywd.259.2018.10.12.15.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 15:45:07 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm: get_user_pages: consolidate error handling
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-2-jhubbard@nvidia.com> <20181012063034.GI8537@350D>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <090e5019-b1b9-fdc5-73a1-902164400fe2@nvidia.com>
Date: Fri, 12 Oct 2018 15:45:05 -0700
MIME-Version: 1.0
In-Reply-To: <20181012063034.GI8537@350D>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/11/18 11:30 PM, Balbir Singh wrote:
> On Thu, Oct 11, 2018 at 11:00:09PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> An upcoming patch requires a way to operate on each page that
>> any of the get_user_pages_*() variants returns.
>>
>> In preparation for that, consolidate the error handling for
>> __get_user_pages(). This provides a single location (the "out:" label)
>> for operating on the collected set of pages that are about to be returned.
>>
>> As long every use of the "ret" variable is being edited, rename
>> "ret" --> "err", so that its name matches its true role.
>> This also gets rid of two shadowed variable declarations, as a
>> tiny beneficial a side effect.
>>
>> Reviewed-by: Jan Kara <jack@suse.cz>
>> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>> ---
> 
> Looks good, might not be needed but
> Reviewed-by: Balbir Singh <bsingharora@gmail.com>
> 

Thanks for the review, very good to have another set of eyes on
this one.

-- 
thanks,
John Hubbard
NVIDIA
