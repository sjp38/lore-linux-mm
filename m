Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 06AA46B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:35:39 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id k14so8491504wgh.24
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:35:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hg1si4313139wib.76.2014.09.25.11.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 11:35:38 -0700 (PDT)
Date: Thu, 25 Sep 2014 14:35:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [next:master 7535/8699] arch/powerpc/mm/hugetlbpage.c:710:1:
 error: conflicting types for 'follow_huge_pud'
Message-ID: <20140925183521.GA9147@nhori.redhat.com>
References: <54245e26.FU1t+9O+nq3emxCs%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54245e26.FU1t+9O+nq3emxCs%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On Fri, Sep 26, 2014 at 02:25:42AM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   8dd2c81f5a94f4b44b7a2f0337caae75ed6a5386
> commit: cc85b60a4616768c88e8e8cb889c55d5284a887b [7535/8699] mm/hugetlb: reduce arch dependent code around follow_huge_*
> config: powerpc-mpc85xx_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout cc85b60a4616768c88e8e8cb889c55d5284a887b
>   # save the attached .config to linux build tree
>   make.cross ARCH=powerpc 
> 
> All error/warnings:
> 
> >> arch/powerpc/mm/hugetlbpage.c:710:1: error: conflicting types for 'follow_huge_pud'
>     follow_huge_pud(struct mm_struct *mm, unsigned long address,
>     ^
>    In file included from arch/powerpc/mm/hugetlbpage.c:14:0:
>    include/linux/hugetlb.h:103:14: note: previous declaration of 'follow_huge_pud' was here
>     struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>                  ^

This build error is already fixed in the following commit.

http://marc.info/?l=linux-mm-commits&m=141150173809685&w=2

Thanks,
Naoya Horiguchi

> 
> vim +/follow_huge_pud +710 arch/powerpc/mm/hugetlbpage.c
> 
>    704	{
>    705		BUG();
>    706		return NULL;
>    707	}
>    708	
>    709	struct page *
>  > 710	follow_huge_pud(struct mm_struct *mm, unsigned long address,
>    711			pmd_t *pmd, int write)
>    712	{
>    713		BUG();
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
