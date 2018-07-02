Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B40F06B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 01:06:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h67-v6so5731914qke.18
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 22:06:57 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r10-v6si3001184qvn.243.2018.07.01.22.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 22:06:56 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
References: <20180702005654.20369-6-jhubbard@nvidia.com>
 <201807021030.EyzuzHW4%fengguang.wu@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <4eb75815-9246-3185-d77f-7718e02bef7c@nvidia.com>
Date: Sun, 1 Jul 2018 22:05:49 -0700
MIME-Version: 1.0
In-Reply-To: <201807021030.EyzuzHW4%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, john.hubbard@gmail.com
Cc: kbuild-all@01.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/01/2018 07:58 PM, kbuild test robot wrote:
> Hi John,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.18-rc3]
> [cannot apply to next-20180629]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/john-hubbard-gmail-com/mm-fs-gup-don-t-unmap-or-drop-filesystem-buffers/20180702-090125
> config: x86_64-randconfig-x010-201826 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from arch/x86/include/asm/atomic.h:5:0,
>                     from include/linux/atomic.h:5,
>                     from include/linux/page_counter.h:5,
>                     from mm/memcontrol.c:34:
>    mm/memcontrol.c: In function 'unlock_page_lru':
>    mm/memcontrol.c:2087:32: error: 'page_tail' undeclared (first use in this function); did you mean 'page_pool'?
>       VM_BUG_ON_PAGE(PageDmaPinned(page_tail), page);
>                                    ^
Yes, that should have been:

        VM_BUG_ON_PAGE(PageDmaPinned(page), page);

Fixed locally...maybe I'll post a v3 right now, as there were half a dozen ridiculous typos that
snuck in.



thanks,
-- 
John Hubbard
NVIDIA
