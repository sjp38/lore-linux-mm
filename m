Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1CB6B063D
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:23:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s14so64820458pgs.4
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:23:19 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z135si20284823pgz.708.2017.08.02.16.23.17
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 16:23:18 -0700 (PDT)
Date: Thu, 3 Aug 2017 08:23:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 5/7] mm: make tlb_flush_pending global
Message-ID: <20170802232316.GA32020@bbox>
References: <20170802000818.4760-6-namit@vmware.com>
 <201708022224.e3s8yqcJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708022224.e3s8yqcJ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Nadav Amit <namit@vmware.com>, kbuild-all@01.org, linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Wed, Aug 02, 2017 at 10:28:47PM +0800, kbuild test robot wrote:
> Hi Minchan,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.13-rc3]
> [cannot apply to next-20170802]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> config: sh-allyesconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/printk.h:6:0,
>                     from include/linux/kernel.h:13,
>                     from mm/debug.c:8:
>    mm/debug.c: In function 'dump_mm':
> >> include/linux/kern_levels.h:4:18: warning: format '%lx' expects argument of type 'long unsigned int', but argument 40 has type 'int' [-Wformat=]

Thanks. lkp.

This patch should fix it.
