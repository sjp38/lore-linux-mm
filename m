Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 76D606B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 20:18:17 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so3820590pdb.22
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 17:18:17 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id os6si9301827pbb.34.2014.11.26.17.18.14
        for <linux-mm@kvack.org>;
        Wed, 26 Nov 2014 17:18:16 -0800 (PST)
Date: Thu, 27 Nov 2014 10:18:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [mmotm:master 174/397] mm/madvise.c:42:7: error: 'MADV_FREE'
 undeclared
Message-ID: <20141127011819.GA21891@bbox>
References: <201411270835.hrrJeFPX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <201411270835.hrrJeFPX%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>

On Thu, Nov 27, 2014 at 08:18:37AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a2d887dee78e23dc092ff14ae2ad22592437a328
> commit: 7eba9427dd923bdf1cc5f88bb0fb880fe1268be0 [174/397] mm: support madvise(MADV_FREE)
> config: xtensa-common_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 7eba9427dd923bdf1cc5f88bb0fb880fe1268be0
>   # save the attached .config to linux build tree
>   make.cross ARCH=xtensa 
> 
> All error/warnings:
> 
>    mm/madvise.c: In function 'madvise_need_mmap_write':
> >> mm/madvise.c:42:7: error: 'MADV_FREE' undeclared (first use in this function)
>      case MADV_FREE:
>           ^
>    mm/madvise.c:42:7: note: each undeclared identifier is reported only once for each function it appears in
>    mm/madvise.c: In function 'madvise_vma':
> >> mm/madvise.c:515:7: error: 'MADV_FREE' undeclared (first use in this function)
>      case MADV_FREE:
>           ^
>    mm/madvise.c: In function 'madvise_behavior_valid':
> >> mm/madvise.c:542:7: error: 'MADV_FREE' undeclared (first use in this function)
>      case MADV_FREE:
>           ^
> 
> vim +/MADV_FREE +42 mm/madvise.c
> 
>     36	static int madvise_need_mmap_write(int behavior)
>     37	{
>     38		switch (behavior) {
>     39		case MADV_REMOVE:
>     40		case MADV_WILLNEED:
>     41		case MADV_DONTNEED:
>   > 42		case MADV_FREE:
>     43			return 0;
>     44		default:
>     45			/* be safe, default to 1. list exceptions explicitly */
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

Thanks.

Below should fix the problem.
