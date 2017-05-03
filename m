Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC9D6B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 02:37:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44so13604300wry.5
        for <linux-mm@kvack.org>; Tue, 02 May 2017 23:37:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si23081924wry.218.2017.05.02.23.37.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 23:37:57 -0700 (PDT)
Date: Wed, 3 May 2017 08:37:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: properly track vmalloc users
Message-ID: <20170503063750.GC1236@dhcp22.suse.cz>
References: <20170502134657.12381-1-mhocko@kernel.org>
 <201705030806.pzzQRBiN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705030806.pzzQRBiN%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-05-17 08:52:01, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on next-20170502]
> [cannot apply to v4.11]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-vmalloc-properly-track-vmalloc-users/20170503-065022
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: m68k-m5475evb_defconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=m68k 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from arch/m68k/include/asm/pgtable_mm.h:145:0,
>                     from arch/m68k/include/asm/pgtable.h:4,
>                     from include/linux/vmalloc.h:9,
>                     from arch/m68k/kernel/module.c:9:

OK, I was little bit worried to pull pgtable.h include in, but my cross
compile build test battery didn't show any issues. I do not have m68k
there though. So let's just do this differently. The following updated
patch hasn't passed the full build test battery but it should just work.

Thanks for your testing.
---
