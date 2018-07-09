Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00ED66B032D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:49:54 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j17-v6so24359726oii.8
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:49:54 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t12-v6si9115406oif.377.2018.07.09.11.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:49:53 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page(), placeholder version
References: <20180709080554.21931-2-jhubbard@nvidia.com>
 <201807091833.xMr1iYDX%fengguang.wu@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <cf746031-b8c7-95de-79cf-b8e5381367c6@nvidia.com>
Date: Mon, 9 Jul 2018 11:48:44 -0700
MIME-Version: 1.0
In-Reply-To: <201807091833.xMr1iYDX%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, john.hubbard@gmail.com
Cc: kbuild-all@01.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/09/2018 03:08 AM, kbuild test robot wrote:
> Hi John,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
...
> 
>>> drivers/platform//goldfish/goldfish_pipe.c:334:13: error: conflicting types for 'release_user_pages'
>     static void release_user_pages(struct page **pages, int pages_count,
>                 ^~~~~~~~~~~~~~~~~~

Yes. Patches #1 and #2 need to be combined here. I'll do that in the next version, which will probably include several of the easier put_user_page() conversions, as well.

thanks,
-- 
John Hubbard
NVIDIA
