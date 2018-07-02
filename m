Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3746A6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 00:41:22 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n23-v6so4246289qtl.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 21:41:22 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k36-v6si925790qvf.138.2018.07.01.21.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 21:41:21 -0700 (PDT)
Subject: Re: [PATCH v2 4/6] mm/fs: add a sync_mode param for
 clear_page_dirty_for_io()
References: <20180702005654.20369-5-jhubbard@nvidia.com>
 <201807020937.9CUpXIGc%fengguang.wu@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ddf3ac95-ce47-41a8-b94b-c7a3d016700f@nvidia.com>
Date: Sun, 1 Jul 2018 21:40:17 -0700
MIME-Version: 1.0
In-Reply-To: <201807020937.9CUpXIGc%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, john.hubbard@gmail.com
Cc: kbuild-all@01.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/01/2018 07:11 PM, kbuild test robot wrote:
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
[...]
>                                             ^
>    include/linux/compiler.h:58:42: note: in definition of macro '__trace_if'
>      if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
>                                              ^~~~
>>> fs/f2fs/data.c:2021:4: note: in expansion of macro 'if'
>        if (!clear_page_dirty_for_io(page), wbc->sync_mode)
>        ^~
>    fs/f2fs/data.c:2021:9: error: too few arguments to function 'clear_page_dirty_for_io'
>        if (!clear_page_dirty_for_io(page), wbc->sync_mode)
>             ^
>    include/linux/compiler.h:69:16: note: in definition of macro '__trace_if'
>       ______r = !!(cond);     \
>                    ^~~~
>>> fs/f2fs/data.c:2021:4: note: in expansion of macro 'if'
>        if (!clear_page_dirty_for_io(page), wbc->sync_mode)
>        ^~

> 

Typo, that should have been:
         if (!clear_page_dirty_for_io(page, wbc->sync_mode))

...fixed locally, I'll include it in the next spin. (Somehow my last build didn't
have all the filesystems enabled, sorry for the glitches.)
   

thanks,
-- 
John Hubbard
NVIDIA
