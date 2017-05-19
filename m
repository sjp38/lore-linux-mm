Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36C0F2806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:08:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c10so55534647pfg.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:08:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n11si8315999pfk.34.2017.05.19.06.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 06:08:29 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4JCwpXC039710
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:08:28 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ahrwn5yf3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:08:28 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 19 May 2017 23:08:26 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4JD8FtH64290824
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:08:23 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4JD7h7w029305
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:07:44 +1000
Subject: Re: [PATCH v5 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 1
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-2-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 19 May 2017 18:37:22 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-2-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <9497ce52-dd0d-0c99-2d0f-de980dfbe28e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, Dave Hansen <dave.hansen@intel.com>, andi.kleen@intel.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
> false negative return when it races with thp spilt
> (during which _PAGE_PRESENT is temporary cleared.) I don't think that
> dropping _PAGE_PSE check in pmd_present() works well because it can
> hurt optimization of tlb handling in thp split.
> In the current kernel, bits 1-4 are not used in non-present format
> since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
> work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
> Bit 7 is used as reserved (always clear), so please don't use it for
> other purpose.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>

+Dave Hansen
+Andi Kleen

Dave/Andi/Kiril,

Does this change looks okay ? Its been on the list for some time
now. Could you please have a look into this and lets us know your
inputs/suggestions/comments ? Thank you.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
