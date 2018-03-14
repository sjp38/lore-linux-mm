Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3C16B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 17:31:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id v8so3994307iob.0
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:31:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g3sor870282itf.36.2018.03.14.14.31.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 14:31:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201803141059.9HN3FiaN%fengguang.wu@intel.com>
References: <201803141059.9HN3FiaN%fengguang.wu@intel.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 14 Mar 2018 22:31:34 +0100
Message-ID: <CAK8P3a1CyFM8i14OVJO7wDL7951wC22BrO-xJCLg9j=+D4BFKw@mail.gmail.com>
Subject: Re: lib///lzo/lzodefs.h:27:2: error: #error "conflicting endian definitions"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Mar 14, 2018 at 3:16 AM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> Hi Arnd,
>
> FYI, the error/warning still remains.
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   fc6eabbbf8ef99efed778dd5afabc83c21dba585
> commit: 101110f6271ce956a049250c907bc960030577f8 Kbuild: always define endianess in kconfig.h
> date:   3 weeks ago
> config: m32r-allmodconfig (attached as .config)
> compiler: m32r-linux-gcc (GCC) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 101110f6271ce956a049250c907bc960030577f8
>         # save the attached .config to linux build tree
>         make.cross ARCH=m32r
>
> All errors (new ones prefixed by >>):
>
>    In file included from arch/m32r/include/uapi/asm/byteorder.h:8:0,
>                     from arch/m32r/include/asm/bitops.h:22,
>                     from include/linux/bitops.h:38,
>                     from include/linux/kernel.h:11,
>                     from include/linux/list.h:9,
>                     from include/linux/module.h:9,
>                     from lib///lzo/lzo1x_compress.c:14:
>    include/linux/byteorder/big_endian.h:8:2: warning: #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN [-Wcpp]
>     #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN

I did now get around to looking at this, sorry for the delay.

The thing is that the warning shows an actual bug when it was previously
broken silently. The configuration sets CONFIG_CPU_LITTLE_ENDIAN
but the compiler only supports big-endian mode.

The m32r architecture is being removed in linux-4.17 as we have shown
that there are no remaining users, so I would suggest not doing anything
here and leaving the warning in place.

       Arnd
