Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC1836B0007
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 09:31:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m19so3574920pgv.5
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 06:31:47 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y8-v6si2668936plk.535.2018.02.17.06.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 06:31:46 -0800 (PST)
Message-ID: <1518877902.22495.374.camel@linux.intel.com>
Subject: Re: [PATCH v1] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Sat, 17 Feb 2018 16:31:42 +0200
In-Reply-To: <201802172101.P4SF4Y50%fengguang.wu@intel.com>
References: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
	 <201802172101.P4SF4Y50%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sat, 2018-02-17 at 21:53 +0800, kbuild test robot wrote:
> Hi Andy,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.16-rc1 next-20180216]
> [if your patch is applied to the wrong git tree, please drop us a note
> to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Andy-Shevchenko/mm-Re
> -use-DEFINE_SHOW_ATTRIBUTE-macro/20180217-204603
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-a1-201806 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/backing-dev.c:104:1: warning: data definition has no type or
> storage class
>     DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
>     ^
>    mm/backing-dev.c:104:1: error: type defaults to 'int' in
> declaration of 'DEFINE_SHOW_ATTRIBUTE' [-Werror=implicit-int]
>    mm/backing-dev.c:104:1: warning: parameter names (without types) in
> function declaration
>    mm/backing-dev.c: In function 'bdi_debug_register':
> > > mm/backing-dev.c:116:19: error: 'bdi_debug_stats_fops' undeclared
> > > (first use in this function)
> 
>                 bdi, &bdi_debug_stats_fops);
>                       ^
>    mm/backing-dev.c:116:19: note: each undeclared identifier is
> reported only once for each function it appears in

But how?! DEFINE_SHOW_ATTRIBUTE() defines ->open() callback along with
struct file_operations.

I have no compilation error with gcc (Debian 7.3.0-3).

>    mm/zsmalloc.c:645:1: warning: data definition has no type or
> storage class
>     DEFINE_SHOW_ATTRIBUTE(zs_stats_size);
>     ^
>    mm/zsmalloc.c:645:1: error: type defaults to 'int' in declaration
> of 'DEFINE_SHOW_ATTRIBUTE' [-Werror=implicit-int]
>    mm/zsmalloc.c:645:1: warning: parameter names (without types) in
> function declaration
>    mm/zsmalloc.c: In function 'zs_pool_stat_create':
> > > mm/zsmalloc.c:664:30: error: 'zs_stat_size_ops' undeclared (first
> > > use in this function)
> 
>        pool->stat_dentry, pool, &zs_st
> at_size_ops);                                 ^

This one valid. Thanks, missed compilation!

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
