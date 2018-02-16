Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3CE76B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:28:19 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id a6so2241669oti.15
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:28:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor8077760oth.155.2018.02.16.12.28.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 12:28:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201802170216.gfRZgPtX%fengguang.wu@intel.com>
References: <201802170216.gfRZgPtX%fengguang.wu@intel.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Feb 2018 21:28:17 +0100
Message-ID: <CAK8P3a1E4=NJaZKM0z8b62ahSoBjR1K2oLsHhbY9C03Kkeeu8g@mail.gmail.com>
Subject: Re: [linux-stable-rc:linux-3.16.y 2872/3488] head64.c:undefined
 reference to `__gcov_exit'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, kbuild-all@01.org, Ben Hutchings <bwh@kernel.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable <stable@vger.kernel.org>

On Fri, Feb 16, 2018 at 7:21 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> Hi Andrey,
>
> It's probably a bug fix that unveils the link errors.
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.16.y
> head:   0b9f4cdd4d75131d8886b919bbf6e0c98906d36e
> commit: 3cb0dc19883f0c69225311d4f76aa8128d3681a4 [2872/3488] module: fix types of device tables aliases
> config: x86_64-allmodconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 3cb0dc19883f0c69225311d4f76aa8128d3681a4
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    arch/x86/kernel/head64.o: In function `_GLOBAL__sub_D_00100_1_early_pmd_flags':
>>> head64.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
>    arch/x86/kernel/head.o: In function `_GLOBAL__sub_D_00100_1_reserve_ebda_region':
>    head.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
>    init/built-in.o: In function `_GLOBAL__sub_D_00100_1___ksymtab_system_state':
>    main.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
>    init/built-in.o: In function `_GLOBAL__sub_D_00100_1_root_mountflags':
>    do_mounts.c:(.text.exit+0x10): undefined reference to `__gcov_exit'
>    init/built-in.o: In function `_GLOBAL__sub_D_00100_1_initrd_load':
>    do_mounts_initrd.c:(.text.exit+0x1b): undefined reference to `__gcov_exit'
>    init/built-in.o:initramfs.c:(.text.exit+0x26): more undefined references to `__gcov_exit' follow

I think this is a result of using a too new compiler with the old 3.16
kernel. In order
to build with gcc-7.3, you need to backport

05384213436a ("gcov: support GCC 7.1")

It's already part of stable-3.18 and later, but not 3.2 and 3.16.

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
