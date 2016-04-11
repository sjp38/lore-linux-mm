Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id CA98D6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 02:05:26 -0400 (EDT)
Received: by mail-io0-f176.google.com with SMTP id o126so173812381iod.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:05:26 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id r18si14076233igs.91.2016.04.10.23.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 23:05:26 -0700 (PDT)
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 11 Apr 2016 16:05:22 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C70212CE805B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:04:57 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3B64nk955443500
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:04:57 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3B64O30004017
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:04:25 +1000
Message-ID: <570B3E51.2090308@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2016 11:34:01 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/hugetlb: Protect follow_huge_(pud|pgd) functions
 from race
References: <201604071708.osnfXWQP%fengguang.wu@intel.com>
In-Reply-To: <201604071708.osnfXWQP%fengguang.wu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: dave.hansen@intel.com, mgorman@techsingularity.net, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kbuild-all@01.org, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, linuxppc-dev@lists.ozlabs.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

On 04/07/2016 03:04 PM, kbuild test robot wrote:
> All errors (new ones prefixed by >>):
> 
>    mm/hugetlb.c: In function 'follow_huge_pud':
>>> >> mm/hugetlb.c:4360:3: error: implicit declaration of function 'pud_page' [-Werror=implicit-function-declaration]
>       page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
>       ^
>    mm/hugetlb.c:4360:8: warning: assignment makes pointer from integer without a cast
>       page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
>            ^
>    mm/hugetlb.c: In function 'follow_huge_pgd':
>    mm/hugetlb.c:4395:3: error: implicit declaration of function 'pgd_page' [-Werror=implicit-function-declaration]
>       page = pgd_page(*pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);

Both the build errors here are because of the fact that pgd_page() is
not available for some platforms and config options. It got missed as
I ran only powerpc config options for build test purpose. My bad, will
fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
