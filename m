Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 055476B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 19:09:28 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so1352378ier.30
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:09:28 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id ci7si998253igb.42.2014.06.18.16.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 16:09:28 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so1362519iec.19
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:09:28 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:09:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32'
 undeclared
In-Reply-To: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.02.1406181607490.22789@chino.kir.corp.google.com>
References: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Will Woods <wwoods@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On Thu, 19 Jun 2014, kbuild test robot wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   e99cfa2d0634881b8a41d56c48b5956b9a3ba162
> commit: 1e2ee49f7f1b79f0b14884fe6a602f0411b39552 fanotify: fix -EOVERFLOW with large files on 64-bit
> date:   6 weeks ago
> config: make ARCH=ia64 allmodconfig
> 
> All error/warnings:
> 
>    fs/notify/fanotify/fanotify_user.c: In function 'SYSC_fanotify_init':
>    fs/notify/fanotify/fanotify_user.c:701:2: error: implicit declaration of function 'personality' [-Werror=implicit-function-declaration]
>      if (force_o_largefile())
>      ^
>    In file included from include/uapi/linux/fcntl.h:4:0,
>                     from include/linux/fcntl.h:4,
>                     from fs/notify/fanotify/fanotify_user.c:2:
> >> arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32' undeclared (first use in this function)
>       (personality(current->personality) != PER_LINUX32)
>                                             ^
>    fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
>      if (force_o_largefile())
>          ^
>    arch/ia64/include/uapi/asm/fcntl.h:9:41: note: each undeclared identifier is reported only once for each function it appears in
>       (personality(current->personality) != PER_LINUX32)
>                                             ^
>    fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
>      if (force_o_largefile())
>          ^
>    cc1: some warnings being treated as errors
> 

I think this wants to add #include <linux/personality.h> to 
arch/ia64/include/uapi/asm/fcntl.h.  I don't think we should be adding it 
to fs/notify/fanotify/fanotify_user.c if 
arch/ia64/include/uapi/asm/fcntl.h strictly requires it.

Yay for build errors reported six weeks later and after 3.15 had been 
released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
