Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFC936B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 16:44:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v3so2121578pfm.21
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:44:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d2si2352853pgc.758.2018.03.14.13.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 13:44:46 -0700 (PDT)
Date: Wed, 14 Mar 2018 13:44:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-4.15 382/386] arch/m68k/mm/init.c:125:0: warning:
 "UL" redefined
Message-Id: <20180314134445.61e26e6038e5c565f1438a9b@linux-foundation.org>
In-Reply-To: <201803142315.LTV2xdYr%fengguang.wu@intel.com>
References: <201803142315.LTV2xdYr%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Wed, 14 Mar 2018 23:20:21 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.15
> head:   5c3f7a041df707417532dd64b1d71fc29b24c0fe
> commit: 145e9c14cca497b2d02f9edcf9307aad5946172f [382/386] linux/const.h: move UL() macro to include/linux/const.h
> config: m68k-sun3_defconfig (attached as .config)
> compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 145e9c14cca497b2d02f9edcf9307aad5946172f
>         # save the attached .config to linux build tree
>         make.cross ARCH=m68k 
> 
> All warnings (new ones prefixed by >>):
> 
>    arch/m68k/mm/init.c: In function 'print_memmap':
> >> arch/m68k/mm/init.c:125:0: warning: "UL" redefined
>     #define UL(x) ((unsigned long) (x))
>     
>    In file included from include/linux/list.h:8:0,
>                     from include/linux/module.h:9,
>                     from arch/m68k/mm/init.c:11:
>    include/linux/const.h:6:0: note: this is the location of the previous definition
>     #define UL(x)  (_UL(x))

That's OK - an unrelated patch in linux-next.patch removes that
#define.
