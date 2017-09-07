Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65E9E2806D8
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 00:50:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g50so2964533wra.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 21:50:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y88si1386962wrb.448.2017.09.06.21.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 21:50:20 -0700 (PDT)
Date: Wed, 6 Sep 2017 21:50:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 143/319] include/linux/swapops.h:224:16: error:
 empty scalar initializer
Message-Id: <20170906215017.a95d6bc457a7c0327e6872c3@linux-foundation.org>
In-Reply-To: <201709071117.XZRVgPlb%fengguang.wu@intel.com>
References: <201709071117.XZRVgPlb%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 7 Sep 2017 11:37:19 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   5e52cc028671694cd84e649e0a43c99a53b1fea1
> commit: ebacb62aac74e6683be1031fed6bfd029732d155 [143/319] mm-thp-enable-thp-migration-in-generic-path-fix-fix-fix
> config: arm-at91_dt_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout ebacb62aac74e6683be1031fed6bfd029732d155
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from fs/proc/task_mmu.c:15:0:
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >> include/linux/swapops.h:224:16: error: empty scalar initializer
>      return (pmd_t){};
>                    ^
>    include/linux/swapops.h:224:16: note: (near initialization for '(anonymous)')
> 
> vim +224 include/linux/swapops.h
> 
>    221	
>    222	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>    223	{
>  > 224		return (pmd_t){};
>    225	}
>    226	

Sigh, I tried.

Zi Yan, we're going to need to find a fix for this.  Rapidly, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
