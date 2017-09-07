Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF7E46B04E6
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 11:09:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e64so1731544wmi.0
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 08:09:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o29si2278398wrf.25.2017.09.07.08.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 08:09:19 -0700 (PDT)
Date: Thu, 7 Sep 2017 08:09:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 143/319] include/linux/swapops.h:224:16: error:
 empty scalar initializer
Message-Id: <20170907080916.a55a3a63ff26424c0d4d49f0@linux-foundation.org>
In-Reply-To: <A8D9CC43-5D31-46D7-B049-A88A027835EA@cs.rutgers.edu>
References: <201709071117.XZRVgPlb%fengguang.wu@intel.com>
	<20170906215017.a95d6bc457a7c0327e6872c3@linux-foundation.org>
	<A8D9CC43-5D31-46D7-B049-A88A027835EA@cs.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 07 Sep 2017 06:54:20 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:

> On 7 Sep 2017, at 0:50, Andrew Morton wrote:
> 
> > On Thu, 7 Sep 2017 11:37:19 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> >
> >> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> >> head:   5e52cc028671694cd84e649e0a43c99a53b1fea1
> >> commit: ebacb62aac74e6683be1031fed6bfd029732d155 [143/319] mm-thp-enable-thp-migration-in-generic-path-fix-fix-fix
> >> config: arm-at91_dt_defconfig (attached as .config)
> >> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> >> reproduce:
> >>         wget https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fraw.githubusercontent.com%2Fintel%2Flkp-tests%2Fmaster%2Fsbin%2Fmake.cross&data=02%7C01%7Czi.yan%40cs.rutgers.edu%7C6ac33fb5121b4518eb6308d4f5abf197%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636403566227996732&sdata=eSBomrixcY9RpH%2BkKovnCQmHlpaOcWXaZ02J0cX%2FQlg%3D&reserved=0 -O ~/bin/make.cross
> >>         chmod +x ~/bin/make.cross
> >>         git checkout ebacb62aac74e6683be1031fed6bfd029732d155
> >>         # save the attached .config to linux build tree
> >>         make.cross ARCH=arm
> >>
> >> All errors (new ones prefixed by >>):
> >>
> >>    In file included from fs/proc/task_mmu.c:15:0:
> >>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >>>> include/linux/swapops.h:224:16: error: empty scalar initializer
> >>      return (pmd_t){};
> >>                    ^
> >>    include/linux/swapops.h:224:16: note: (near initialization for '(anonymous)')
> >>
> >> vim +224 include/linux/swapops.h
> >>
> >>    221	
> >>    222	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> >>    223	{
> >>> 224		return (pmd_t){};
> >>    225	}
> >>    226	
> >
> > Sigh, I tried.
> >
> > Zi Yan, we're going to need to find a fix for this.  Rapidly, please.
> 
> 
> Hi Andrew,
> 
> Why cannot we use __pmd(0) instead? My sparc32 fix is in 4.13 now.
> commit is 9157259d16a8ee8116a98d32f29b797689327e8d.

I didn't know that.  So we should be OK now.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
