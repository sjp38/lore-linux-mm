Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA7F6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:23:55 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so39228112pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:23:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xy3si5107463pbc.188.2015.03.25.13.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 13:23:54 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:23:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 219/458] mm/huge_memory.c:1397:3: error: implicit
 declaration of function 'pmd_mkclean'
Message-Id: <20150325132353.ce2c6461f8ce8bb083004af8@linux-foundation.org>
In-Reply-To: <201503251512.LuQ8VtXp%fengguang.wu@intel.com>
References: <201503251512.LuQ8VtXp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 25 Mar 2015 15:16:14 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   e077e8e0158533bb824f3e2d9c0eaaaf4679b0ca
> commit: 2f7e175e0801020803aeba52576d53c0fe69805b [219/458] mm: don't split THP page when syscall is called
> config: i386-randconfig-nexr0-0322 (attached as .config)
> reproduce:
>   git checkout 2f7e175e0801020803aeba52576d53c0fe69805b
>   # save the attached .config to linux build tree
>   make ARCH=i386 
> 
> Note: the mmotm/master HEAD e077e8e0158533bb824f3e2d9c0eaaaf4679b0ca builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    mm/huge_memory.c: In function 'madvise_free_huge_pmd':
> >> mm/huge_memory.c:1397:3: error: implicit declaration of function 'pmd_mkclean' [-Werror=implicit-function-declaration]
>       orig_pmd = pmd_mkclean(orig_pmd);
>       ^
> >> mm/huge_memory.c:1397:12: error: incompatible types when assigning to type 'pmd_t' from type 'int'
>       orig_pmd = pmd_mkclean(orig_pmd);
>                ^
>    cc1: some warnings being treated as errors

Thanks.  I reordered things so

x86-add-pmd_-for-thp.patch
x86-add-pmd_-for-thp-fix.patch
sparc-add-pmd_-for-thp.patch
sparc-add-pmd_-for-thp-fix.patch
powerpc-add-pmd_-for-thp.patch
arm-add-pmd_mkclean-for-thp.patch
arm64-add-pmd_-for-thp.patch

come before

mm-support-madvisemadv_free.patch
mm-support-madvisemadv_free-fix.patch
mm-support-madvisemadv_free-fix-2.patch
mm-dont-split-thp-page-when-syscall-is-called.patch
mm-dont-split-thp-page-when-syscall-is-called-fix.patch
mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
mm-free-swp_entry-in-madvise_free.patch
mm-move-lazy-free-pages-to-inactive-list.patch

which should fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
