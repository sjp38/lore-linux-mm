Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A14E26B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:52:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so317565038pfc.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 01:52:24 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [125.16.236.8])
        by mx.google.com with ESMTPS id uy10si4283524pac.210.2016.04.18.01.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 01:52:23 -0700 (PDT)
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 18 Apr 2016 14:22:21 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3I8qIOp36700364
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:22:18 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3I8qGIO013024
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:22:18 +0530
Message-ID: <5714A040.9090903@linux.vnet.ibm.com>
Date: Mon, 18 Apr 2016 14:22:16 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] Enable HugeTLB page migration on POWER
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 04/07/2016 11:07 AM, Anshuman Khandual wrote:
> This patch series enables HugeTLB page migration on POWER platform.
> This series has some core VM changes (patch 1, 2, 3) and some powerpc
> specific changes (patch 4, 5, 6, 7, 8, 9, 10). Comments, suggestions
> and inputs are welcome.
> 
> Anshuman Khandual (10):
>   mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK inside mmap_pgoff
>   mm/hugetlb: Add PGD based implementation awareness
>   mm/hugetlb: Protect follow_huge_(pud|pgd) functions from race

Hugh/Mel/Naoya/Andrew,

Andrew had already reviewed the changes in the first two patches during
the RFC phase and was okay with them. Could you please review the third
patch here as well and let me know your inputs/suggestions. Currently
the third patch has got build failures on SPARC and S390 platforms
(details of which are on the thread with possible fixes). Thank you.



	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
