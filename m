Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFF606B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 15:48:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16-v6so3477533pfn.5
        for <linux-mm@kvack.org>; Fri, 25 May 2018 12:48:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l7-v6si14239205pgq.121.2018.05.25.12.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 12:48:49 -0700 (PDT)
Date: Fri, 25 May 2018 12:48:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 174/217] inode.c:(.text+0x170): multiple
 definition of `autofs_new_ino'
Message-Id: <20180525124848.258056ff105877205962fdb5@linux-foundation.org>
In-Reply-To: <1527227658.2695.5.camel@themaw.net>
References: <201805251046.ncc27YbY%fengguang.wu@intel.com>
	<1527227658.2695.5.camel@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Kent <raven@themaw.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 25 May 2018 13:54:18 +0800 Ian Kent <raven@themaw.net> wrote:

> On Fri, 2018-05-25 at 10:19 +0800, kbuild test robot wrote:
> 
> Andrew,
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   0b018d19da6c907a81867c5743aad0b7e0a225ab
> > commit: 17a2d85727768517003e45933a7118a48fe36f34 [174/217] autofs: create
> > autofs Kconfig and Makefile
> > config: i386-allyesconfig (attached as .config)
> > compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> > reproduce:
> >         git checkout 17a2d85727768517003e45933a7118a48fe36f34
> >         # save the attached .config to linux build tree
> >         make ARCH=i386 
> > 
> > Note: the mmotm/master HEAD 0b018d19da6c907a81867c5743aad0b7e0a225ab builds
> > fine.
> >       It only hurts bisectibility.
> 
> Looks like my ordering is wrong.
> 
> Moving:
> autofs - create autofs Kconfig and Makefile
> 
> three patches down to below:
> autofs - delete fs/autofs4 source files
> 
> can be done without problem and should preserve bisectibility.

I did that.

autofs4-merge-auto_fsh-and-auto_fs4h.patch
autofs4-use-autofs-instead-of-autofs4-everywhere.patch
autofs-copy-autofs4-to-autofs.patch
autofs-update-fs-autofs4-kconfig.patch
autofs-update-fs-autofs4-kconfig-fix.patch
autofs-update-fs-autofs4-makefile.patch
autofs-delete-fs-autofs4-source-files.patch
autofs-create-autofs-kconfig-and-makefile.patch
autofs-rename-autofs-documentation-files.patch
autofs-use-autofs-instead-of-autofs4-in-documentation.patch
autofs-update-maintainers-entry-for-autofs.patch
