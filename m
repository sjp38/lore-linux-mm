Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF99A6B0579
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 17:38:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d24so3784401wmi.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 14:38:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 204si1934114wmw.252.2017.08.01.14.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 14:38:55 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:38:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 50/189] include/linux/swapops.h:220:9: error:
 implicit declaration of function '__pmd'
Message-Id: <20170801143853.f210976a43d009dba1eeb0db@linux-foundation.org>
In-Reply-To: <201708011949.LtRajyO5%fengguang.wu@intel.com>
References: <201708011949.LtRajyO5%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, sparclinux@vger.kernel.org

On Tue, 1 Aug 2017 19:57:54 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7961d18ba492e06ad240d37a5502c418b5f0a928
> commit: 25faf0ef110322719330fcadf4fe541528bacd4d [50/189] mm-thp-enable-thp-migration-in-generic-path-fix
> config: sparc-defconfig (attached as .config)
> compiler: sparc-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 25faf0ef110322719330fcadf4fe541528bacd4d
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from fs/proc/task_mmu.c:15:0:
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >> include/linux/swapops.h:220:9: error: implicit declaration of function '__pmd' [-Werror=implicit-function-declaration]
>      return __pmd(0);
>             ^~~~~
> >> include/linux/swapops.h:220:9: error: incompatible types when returning type 'int' but 'pmd_t {aka struct <anonymous>}' was expected
>      return __pmd(0);
>             ^~~~~~~~
>    cc1: some warnings being treated as errors
> 
> vim +/__pmd +220 include/linux/swapops.h
> 
>    217	
>    218	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>    219	{
>  > 220		return __pmd(0);
>    221	}
>    222	
> 

Seems that sparc32 forgot to implement __pmd()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
