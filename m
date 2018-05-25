Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B78F6B02D5
	for <linux-mm@kvack.org>; Fri, 25 May 2018 01:54:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y124-v6so3086511qkc.8
        for <linux-mm@kvack.org>; Thu, 24 May 2018 22:54:27 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id d7-v6si262511qka.61.2018.05.24.22.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 22:54:22 -0700 (PDT)
Message-ID: <1527227658.2695.5.camel@themaw.net>
Subject: Re: [mmotm:master 174/217] inode.c:(.text+0x170): multiple
 definition of `autofs_new_ino'
From: Ian Kent <raven@themaw.net>
Date: Fri, 25 May 2018 13:54:18 +0800
In-Reply-To: <201805251046.ncc27YbY%fengguang.wu@intel.com>
References: <201805251046.ncc27YbY%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 2018-05-25 at 10:19 +0800, kbuild test robot wrote:

Andrew,

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   0b018d19da6c907a81867c5743aad0b7e0a225ab
> commit: 17a2d85727768517003e45933a7118a48fe36f34 [174/217] autofs: create
> autofs Kconfig and Makefile
> config: i386-allyesconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout 17a2d85727768517003e45933a7118a48fe36f34
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> Note: the mmotm/master HEAD 0b018d19da6c907a81867c5743aad0b7e0a225ab builds
> fine.
>       It only hurts bisectibility.

Looks like my ordering is wrong.

Moving:
autofs - create autofs Kconfig and Makefile

three patches down to below:
autofs - delete fs/autofs4 source files

can be done without problem and should preserve bisectibility.

> 
> All errors (new ones prefixed by >>):
> 
>    fs/autofs4/inode.o: In function `autofs_new_ino':
> > > inode.c:(.text+0x170): multiple definition of `autofs_new_ino'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x170): first defined here
>    fs/autofs4/inode.o: In function `autofs_clean_ino':
> > > inode.c:(.text+0x1c0): multiple definition of `autofs_clean_ino'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x1c0): first defined here
>    fs/autofs4/inode.o: In function `autofs_free_ino':
> > > inode.c:(.text+0x1f0): multiple definition of `autofs_free_ino'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x1f0): first defined here
>    fs/autofs4/inode.o: In function `autofs_kill_sb':
> > > inode.c:(.text+0x200): multiple definition of `autofs_kill_sb'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x200): first defined here
>    fs/autofs4/inode.o: In function `autofs_get_inode':
> > > inode.c:(.text+0x250): multiple definition of `autofs_get_inode'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x250): first defined here
>    fs/autofs4/inode.o: In function `autofs_fill_super':
> > > inode.c:(.text+0x300): multiple definition of `autofs_fill_super'
> 
>    fs/autofs/inode.o:inode.c:(.text+0x300): first defined here
>    fs/autofs4/root.o: In function `is_autofs_dentry':
> > > root.c:(.text+0x1170): multiple definition of `is_autofs_dentry'
> 
>    fs/autofs/root.o:root.c:(.text+0x1170): first defined here
> > > fs/autofs4/root.o:(.rodata+0x0): multiple definition of
> > > `autofs_dentry_operations'
> 
>    fs/autofs/root.o:(.rodata+0x0): first defined here
> > > fs/autofs4/root.o:(.rodata+0x40): multiple definition of
> > > `autofs_dir_inode_operations'
> 
>    fs/autofs/root.o:(.rodata+0x40): first defined here
> > > fs/autofs4/root.o:(.rodata+0xc0): multiple definition of
> > > `autofs_dir_operations'
> 
>    fs/autofs/root.o:(.rodata+0xc0): first defined here
> > > fs/autofs4/root.o:(.rodata+0x140): multiple definition of
> > > `autofs_root_operations'
> 
>    fs/autofs/root.o:(.rodata+0x140): first defined here
> > > fs/autofs4/symlink.o:(.rodata+0x0): multiple definition of
> > > `autofs_symlink_inode_operations'
> 
>    fs/autofs/symlink.o:(.rodata+0x0): first defined here
>    fs/autofs4/waitq.o: In function `autofs_catatonic_mode':
>    waitq.c:(.text+0x60): multiple definition of `autofs_catatonic_mode'
>    fs/autofs/waitq.o:waitq.c:(.text+0x60): first defined here
>    fs/autofs4/waitq.o: In function `autofs_wait_release':
>    waitq.c:(.text+0x110): multiple definition of `autofs_wait_release'
>    fs/autofs/waitq.o:waitq.c:(.text+0x110): first defined here
>    fs/autofs4/waitq.o: In function `autofs_wait':
>    waitq.c:(.text+0x520): multiple definition of `autofs_wait'
>    fs/autofs/waitq.o:waitq.c:(.text+0x520): first defined here
>    fs/autofs4/expire.o: In function `autofs_expire_direct':
>    expire.c:(.text+0x4d0): multiple definition of `autofs_expire_direct'
>    fs/autofs/expire.o:expire.c:(.text+0x4d0): first defined here
>    fs/autofs4/expire.o: In function `autofs_expire_indirect':
>    expire.c:(.text+0x5c0): multiple definition of `autofs_expire_indirect'
>    fs/autofs/expire.o:expire.c:(.text+0x5c0): first defined here
>    fs/autofs4/expire.o: In function `autofs_expire_wait':
>    expire.c:(.text+0x840): multiple definition of `autofs_expire_wait'
>    fs/autofs/expire.o:expire.c:(.text+0x840): first defined here
>    fs/autofs4/expire.o: In function `autofs_expire_run':
>    expire.c:(.text+0x910): multiple definition of `autofs_expire_run'
>    fs/autofs/expire.o:expire.c:(.text+0x910): first defined here
>    fs/autofs4/expire.o: In function `autofs_do_expire_multi':
>    expire.c:(.text+0xa30): multiple definition of `autofs_do_expire_multi'
>    fs/autofs/expire.o:expire.c:(.text+0xa30): first defined here
>    fs/autofs4/expire.o: In function `autofs_expire_multi':
>    expire.c:(.text+0xb00): multiple definition of `autofs_expire_multi'
>    fs/autofs/expire.o:expire.c:(.text+0xb00): first defined here
>    fs/autofs4/dev-ioctl.o: In function `autofs_dev_ioctl_init':
>    dev-ioctl.c:(.init.text+0x0): multiple definition of
> `autofs_dev_ioctl_init'
>    fs/autofs/dev-ioctl.o:dev-ioctl.c:(.init.text+0x0): first defined here
>    fs/autofs4/dev-ioctl.o: In function `autofs_dev_ioctl_exit':
>    dev-ioctl.c:(.text+0xac0): multiple definition of `autofs_dev_ioctl_exit'
>    fs/autofs/dev-ioctl.o:dev-ioctl.c:(.text+0xac0): first defined here
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
