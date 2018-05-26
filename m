Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE056B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 23:48:08 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f35-v6so4147797plb.10
        for <linux-mm@kvack.org>; Fri, 25 May 2018 20:48:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 136-v6si1664581pgf.604.2018.05.25.20.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 20:48:07 -0700 (PDT)
Date: Fri, 25 May 2018 20:48:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm-kasan-dont-vfree-nonexistent-vm_area-fix
Message-Id: <20180525204804.3a655370ef4b41e0d96e03f3@linux-foundation.org>
In-Reply-To: <201805261122.HdUpobQm%fengguang.wu@intel.com>
References: <dabee6ab-3a7a-51cd-3b86-5468718e0390@virtuozzo.com>
	<201805261122.HdUpobQm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, kbuild-all@01.org, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Ian Kent <raven@themaw.net>

On Sat, 26 May 2018 11:31:35 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi Andrey,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on mmotm/master]
> [cannot apply to v4.17-rc6]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Andrey-Ryabinin/mm-kasan-dont-vfree-nonexistent-vm_area-fix/20180526-093255
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: sparc-allyesconfig (attached as .config)
> compiler: sparc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc 
> 
> All errors (new ones prefixed by >>):
> 
>    fs/autofs/inode.o: In function `autofs_new_ino':
>    inode.c:(.text+0x220): multiple definition of `autofs_new_ino'
>    fs/autofs/inode.o:inode.c:(.text+0x220): first defined here
>    fs/autofs/inode.o: In function `autofs_clean_ino':
>    inode.c:(.text+0x280): multiple definition of `autofs_clean_ino'
>    fs/autofs/inode.o:inode.c:(.text+0x280): first defined here

There's bot breakage here - clearly that patch didn't cause this error.

Ian, this autofs glitch may still not be fixed.
