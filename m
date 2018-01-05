Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE262280265
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 04:07:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so2544014pff.0
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 01:07:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j76si685445pgc.744.2018.01.05.01.07.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 01:07:57 -0800 (PST)
Date: Fri, 5 Jan 2018 10:07:53 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm:master 149/256] mm/migrate.c:1920:46: error: passing
 argument 2 of 'migrate_pages' from incompatible pointer type
Message-ID: <20180105090753.GI2801@dhcp22.suse.cz>
References: <201801051045.4sj2RvmD%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801051045.4sj2RvmD%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux Memory Management List <linux-mm@kvack.org>

On Fri 05-01-18 10:56:50, Wu Fengguang wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   1ceb98996d2504dd4e0bcb5f4cb9009a18cd8aaa
> commit: c714f7da3636f838c8ed46c7c477525c2ea98a0f [149/256] mm, migrate: remove reason argument from new_page_t
> config: x86_64-lkp (attached as .config)
> compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
> reproduce:
>         git checkout c714f7da3636f838c8ed46c7c477525c2ea98a0f
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/migrate.c: In function 'migrate_misplaced_page':
> >> mm/migrate.c:1920:46: error: passing argument 2 of 'migrate_pages' from incompatible pointer type [-Werror=incompatible-pointer-types]
>      nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
>                                                  ^~~~~~~~~~~~~~~~~~~~~~~~
>    mm/migrate.c:1364:5: note: expected 'struct page * (*)(struct page *, long unsigned int)' but argument is of type 'struct page * (*)(struct page *, long unsigned int,  int **)'
>     int migrate_pages(struct list_head *from, new_page_t get_new_page,
>         ^~~~~~~~~~~~~
>    cc1: some warnings being treated as errors

Doh. Yet another follow up fix for mm-migrate-remove-reason-argument-from-new_page_t.patch
---
