Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9951F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:39:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 144so26625693pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:39:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t6si4949688pfa.280.2016.11.07.03.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:39:47 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7Bcm6X079101
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 06:39:47 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26jnwkgth3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 06:39:47 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 04:39:46 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: move vma_is_anonymous check within pmd_move_must_withdraw
In-Reply-To: <201611071732.njM40txT%fengguang.wu@intel.com>
References: <201611071732.njM40txT%fengguang.wu@intel.com>
Date: Mon, 07 Nov 2016 17:09:36 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8737j3h62v.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

kbuild test robot <lkp@intel.com> writes:

> Hi Aneesh,
>
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.9-rc4 next-20161028]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Aneesh-Kumar-K-V/mm-move-vma_is_anonymous-check-within-pmd_move_must_withdraw/20161107-164033
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x006-201645 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> All error/warnings (new ones prefixed by >>):
>
>    mm/huge_memory.c: In function 'pmd_move_must_withdraw':
>>> mm/huge_memory.c:1441:58: error: 'vma' undeclared (first use in this function)
>      return (new_pmd_ptl != old_pmd_ptl) && vma_is_anonymous(vma);
>                                                              ^~~
>    mm/huge_memory.c:1441:58: note: each undeclared identifier is reported only once for each function it appears in
>>> mm/huge_memory.c:1442:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
>
> vim +/vma +1441 mm/huge_memory.c
>
>   1435		/*
>   1436		 * With split pmd lock we also need to move preallocated
>   1437		 * PTE page table if new_pmd is on different PMD page table.
>   1438		 *
>   1439		 * We also don't deposit and withdraw tables for file pages.
>   1440		 */
>> 1441		return (new_pmd_ptl != old_pmd_ptl) && vma_is_anonymous(vma);
>> 1442	}
>   1443	#endif
>   1444	
>   1445	bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>

My bad, I didn't test with hugepage enabled for x86. Will fixup in the
next update.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
