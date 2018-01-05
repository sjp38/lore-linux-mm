Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79D26280265
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 03:53:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so269020wmb.9
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 00:53:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j26si4006801wre.336.2018.01.05.00.53.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 00:53:01 -0800 (PST)
Date: Fri, 5 Jan 2018 09:52:59 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm:master 149/256] mm/memory-failure.c:1587:33: error:
 passing argument 2 of 'migrate_pages' from incompatible pointer type
Message-ID: <20180105085259.GH2801@dhcp22.suse.cz>
References: <201801051033.yyDREhgU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801051033.yyDREhgU%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux Memory Management List <linux-mm@kvack.org>

Hi,

On Fri 05-01-18 10:51:40, Wu Fengguang wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   1ceb98996d2504dd4e0bcb5f4cb9009a18cd8aaa
> commit: c714f7da3636f838c8ed46c7c477525c2ea98a0f [149/256] mm, migrate: remove reason argument from new_page_t
> config: i386-randconfig-i1-201800 (attached as .config)
> compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
> reproduce:
>         git checkout c714f7da3636f838c8ed46c7c477525c2ea98a0f
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/memory-failure.c: In function 'soft_offline_huge_page':
> >> mm/memory-failure.c:1587:33: error: passing argument 2 of 'migrate_pages' from incompatible pointer type [-Werror=incompatible-pointer-types]
>      ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                                     ^~~~~~~~
>    In file included from mm/memory-failure.c:51:0:
>    include/linux/migrate.h:68:12: note: expected 'struct page * (*)(struct page *, long unsigned int)' but argument is of type 'struct page * (*)(struct page *, long unsigned int,  int **)'
>     extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
>                ^~~~~~~~~~~~~
>    mm/memory-failure.c: In function '__soft_offline_page':
>    mm/memory-failure.c:1665:34: error: passing argument 2 of 'migrate_pages' from incompatible pointer type [-Werror=incompatible-pointer-types]
>       ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                                      ^~~~~~~~
>    In file included from mm/memory-failure.c:51:0:
>    include/linux/migrate.h:68:12: note: expected 'struct page * (*)(struct page *, long unsigned int)' but argument is of type 'struct page * (*)(struct page *, long unsigned int,  int **)'
>     extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
>                ^~~~~~~~~~~~~
>    cc1: some warnings being treated as errors

Sorry about missing this one. I am wondering none of my configs has
CONFIG_MEMORY_FAILURE enabled... I've fixed that. Anyway, the fix is
trivial. Andrew, could you fold it to mm-migrate-remove-reason-argument-from-new_page_t.patch
---
