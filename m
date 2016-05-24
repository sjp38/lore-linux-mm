Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 627D06B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 15:44:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 129so48208566pfx.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 12:44:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xw3si6649698pac.156.2016.05.24.12.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 12:44:58 -0700 (PDT)
Date: Tue, 24 May 2016 12:44:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 11896/11991]
 include/linux/page_idle.h:49:19: warning: unused variable 'page_ext'
Message-Id: <20160524124457.2fa8fca1db728522fd22de54@linux-foundation.org>
In-Reply-To: <201605241820.dS1jQptn%fengguang.wu@intel.com>
References: <201605241820.dS1jQptn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Yang Shi <yang.shi@linaro.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 24 May 2016 18:48:23 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   66c198deda3725c57939c6cdaf2c9f5375cd79ad
> commit: 186ba1a848cef542bdf7c881f863783e9e7a91df [11896/11991] mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-checkpatch-fixes
> config: i386-randconfig-h1-05241552 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout 186ba1a848cef542bdf7c881f863783e9e7a91df
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>                                  ^~~~~~~~~~~~~~~~~~~~~~~~
>    fs/proc/task_mmu.c:408:30: warning: unused variable 'proc_pid_maps_operations' [-Wunused-variable]
>     const struct file_operations proc_pid_maps_operations = {
>                                  ^~~~~~~~~~~~~~~~~~~~~~~

Confused.  proc_pid_maps_operations is referenced from fs/proc/base.o.

>    In file included from fs/proc/task_mmu.c:22:0:
>    fs/proc/internal.h:299:37: warning: unused variable 'proc_pagemap_operations' [-Wunused-variable]
>     extern const struct file_operations proc_pagemap_operations;
>                                         ^~~~~~~~~~~~~~~~~~~~~~~

Even more confused.  Your config has CONFIG_PROC_PAGE_MONITOR=n, so
proc_pagemap_operations doesn't get past the cpp stage.


>    In file included from fs/proc/task_mmu.c:16:0:
> >> include/linux/page_idle.h:49:19: warning: unused variable 'page_ext' [-Wunused-variable]
>      struct page_ext *page_ext = lookup_page_ext(page);

This is the new one and is presumably caused by the great stream of
missing ')'s in the CONFIG_64BIT=n section of page_idle.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
