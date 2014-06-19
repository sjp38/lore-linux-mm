Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id A61376B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 04:33:59 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so1741665iec.9
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:33:59 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id mb9si7615488icc.18.2014.06.19.01.33.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 01:33:59 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id y20so1715986ier.4
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:33:58 -0700 (PDT)
Date: Thu, 19 Jun 2014 01:33:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [next:master 77/159] fs/proc/task_mmu.c:505:193: error: call to
 '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
In-Reply-To: <53a29abf.v2bhnSChDbNTCQGt%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.02.1406190133060.13670@chino.kir.corp.google.com>
References: <53a29abf.v2bhnSChDbNTCQGt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On Thu, 19 Jun 2014, kbuild test robot wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   07d0e2d232fee3ff692c50150b2aa6e3b7755f8f
> commit: b0e08c526179642dccfd2c7caff31d2419492829 [77/159] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
> config: make ARCH=i386 defconfig
> 
> Note: the next/master HEAD 07d0e2d232fee3ff692c50150b2aa6e3b7755f8f builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    fs/proc/task_mmu.c: In function 'smaps_pmd':
> >> fs/proc/task_mmu.c:505:193: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
>      smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
>                                                                                                                                                                                                     ^
> >> fs/proc/task_mmu.c:506:178: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed
>      mss->anonymous_thp += HPAGE_PMD_SIZE;
>                                                                                                                                                                                      ^

mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code.patch 
was removed from -mm on Monday.  We probably need to wait for another 
mmotm before this vanishes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
