Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9E756B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 15:35:04 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j100so4168108wrj.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 12:35:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r6si626926wre.386.2018.02.22.12.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 12:35:03 -0800 (PST)
Date: Thu, 22 Feb 2018 12:35:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 42/152] mm/page_alloc.c:1602:18: error: 'struct
 zone' has no member named 'node'; did you mean 'name'?
Message-Id: <20180222123500.cf6185e02bdb3f4af50902c2@linux-foundation.org>
In-Reply-To: <201802230210.xvEwoWBG%fengguang.wu@intel.com>
References: <201802230210.xvEwoWBG%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 23 Feb 2018 02:36:12 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   745388a34645dd2b69f5e7115ad47fea7a218726
> commit: cb9cc5caafb2b2ad1db9742432754913d36f9cec [42/152] mm: initialize pages on demand during boot
> config: x86_64-randconfig-a0-02221139 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout cb9cc5caafb2b2ad1db9742432754913d36f9cec
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the mmotm/master HEAD 745388a34645dd2b69f5e7115ad47fea7a218726 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    mm/page_alloc.c: In function 'deferred_grow_zone':
> >> mm/page_alloc.c:1602:18: error: 'struct zone' has no member named 'node'; did you mean 'name'?
>      int nid = zone->node;
>                      ^~~~
>                      name

THis is fixed in the following patch,
mm-initialize-pages-on-demand-during-boot-fix-3.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
