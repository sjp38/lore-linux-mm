Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF8D6B0038
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 23:20:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b78so17388775wrd.18
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 20:20:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h7si18696971wrc.138.2017.04.17.20.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 20:20:19 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I3JhO9069446
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 23:20:17 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29w00kq3gk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 23:20:17 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Apr 2017 13:20:14 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I3K3Oj4980832
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 13:20:11 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I3JcGm003773
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 13:19:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] mm/follow_page_mask: Add support for hugepage directory entry
In-Reply-To: <201704180224.jNqHZuTL%fengguang.wu@intel.com>
References: <201704180224.jNqHZuTL%fengguang.wu@intel.com>
Date: Tue, 18 Apr 2017 08:49:14 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87a87eh07h.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

kbuild test robot <lkp@intel.com> writes:

> Hi Aneesh,
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.11-rc7 next-20170413]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Aneesh-Kumar-K-V/HugeTLB-migration-support-for-PPC64/20170418-011540
> config: x86_64-randconfig-a0-04180109 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
>
> All errors (new ones prefixed by >>):
>
>    In file included from mm//swap.c:35:
>>> include/linux/hugetlb.h:121: error: expected declaration specifiers or '...' before 'hugepd_t'
>
> vim +121 include/linux/hugetlb.h
>
>    115				unsigned long addr, unsigned long sz);
>    116	pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
>    117	int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
>    118	struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
>    119				      int write);
>    120	struct page *follow_huge_pd(struct vm_area_struct *vma,
>  > 121				    unsigned long address, hugepd_t hpd,
>    122				    int flags, int pdshift);
>    123	struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>    124					pmd_t *pmd, int flags);
>

Thanks for the report. How about
