Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2676B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 04:07:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so419915268pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:07:54 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10047.outbound.protection.outlook.com. [40.107.1.47])
        by mx.google.com with ESMTPS id c17si58976551pgj.137.2016.11.29.01.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 01:07:53 -0800 (PST)
Date: Tue, 29 Nov 2016 17:07:41 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 0/6] mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161129090739.GC16569@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <6b83ea5d-a465-7582-a215-51a21fb4ce2e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <6b83ea5d-a465-7582-a215-51a21fb4ce2e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon, Nov 28, 2016 at 03:20:05PM +0100, Vlastimil Babka wrote:
> > Huang Shijie (6):
> >   mm: hugetlb: rename some allocation functions
> >   mm: hugetlb: add a new parameter for some functions
> >   mm: hugetlb: change the return type for alloc_fresh_gigantic_page
> >   mm: mempolicy: intruduce a helper huge_nodemask()
> >   mm: hugetlb: add a new function to allocate a new gigantic page
> >   mm: hugetlb: support gigantic surplus pages
> > 
> >  include/linux/mempolicy.h |   8 +++
> >  mm/hugetlb.c              | 128 ++++++++++++++++++++++++++++++++++++----------
> >  mm/mempolicy.c            |  20 ++++++++
> >  3 files changed, 130 insertions(+), 26 deletions(-)
> 
> Can't say I'm entirely happy with the continued direction of maze of
> functions for huge page allocation :( Feels like path of least resistance to
> basically copy/paste the missing parts here. Is there no way to consolidate
> the code more?
Ok, I will spend some time to read the code and think about it.

If you have interest, please do it too. :)

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
