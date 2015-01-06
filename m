Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id E12476B010D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:34:59 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id u10so1532291lbd.13
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:34:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ln11si67324844lac.114.2015.01.06.11.34.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 11:34:58 -0800 (PST)
Date: Tue, 6 Jan 2015 14:34:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [cgroup:review-cgroup-writeback-20150106 65/265]
 mm/page-writeback.c:2314:10: error: too few arguments to function
 'mem_cgroup_begin_page_stat'
Message-ID: <20150106193341.GA30362@phnom.home.cmpxchg.org>
References: <201501070312.c0o38bh9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201501070312.c0o38bh9%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Jan 07, 2015 at 03:22:14AM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150106
> head:   393b71c00e25227a020f9dbf8ffdddebac4fdf1e
> commit: db73c712993c8bea02a97a5e936f965efc1de435 [65/265] mm: memcontrol: track move_lock state internally
> config: parisc-c3000_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout db73c712993c8bea02a97a5e936f965efc1de435
>   # save the attached .config to linux build tree
>   make.cross ARCH=parisc 
> 
> All error/warnings:
> 
>    mm/page-writeback.c: In function 'test_clear_page_writeback':
> >> mm/page-writeback.c:2314:10: error: too few arguments to function 'mem_cgroup_begin_page_stat'
>      memcg = mem_cgroup_begin_page_stat(page);
>              ^
>    In file included from include/linux/swap.h:8:0,
>                     from mm/page-writeback.c:19:
>    include/linux/memcontrol.h:286:34: note: declared here
>     static inline struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,

Andrew, could you please fold the following fix?  Thanks!
