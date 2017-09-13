Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51DC06B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 20:16:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so22738353pfl.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 17:16:47 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 20si1449516pfh.375.2017.09.12.17.16.45
        for <linux-mm@kvack.org>;
        Tue, 12 Sep 2017 17:16:46 -0700 (PDT)
Date: Wed, 13 Sep 2017 09:16:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm:swap: skip swapcache for swapin of synchronous
 device
Message-ID: <20170913001644.GA29422@bbox>
References: <1505183833-4739-5-git-send-email-minchan@kernel.org>
 <201709130400.WopzLnEI%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709130400.WopzLnEI%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Wed, Sep 13, 2017 at 04:22:59AM +0800, kbuild test robot wrote:
> Hi Minchan,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on next-20170912]
> [cannot apply to linus/master v4.13]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Minchan-Kim/zram-set-BDI_CAP_STABLE_WRITES-once/20170913-025838
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x016-201737 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):

I will fix !CONFIG_SWAP.
Thanks, 0-day!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
