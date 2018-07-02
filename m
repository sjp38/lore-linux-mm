Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2D476B0289
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 17:35:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o6-v6so3755156qtp.15
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 14:35:51 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f3-v6si1383245qvi.172.2018.07.02.14.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 14:35:51 -0700 (PDT)
Subject: Re: [PATCH v2 1/6] mm: get_user_pages: consolidate error handling
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-2-jhubbard@nvidia.com>
 <20180702101725.esnjyo4zp3726i3n@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2bb69d70-33c4-3547-823d-4750df237d83@nvidia.com>
Date: Mon, 2 Jul 2018 14:34:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180702101725.esnjyo4zp3726i3n@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/02/2018 03:17 AM, Jan Kara wrote:
> On Sun 01-07-18 17:56:49, john.hubbard@gmail.com wrote:
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
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> 
> This looks nice! You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 

Great, thanks for the review!

-- 
John Hubbard
NVIDIA
