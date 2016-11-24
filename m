Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0A616B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:39:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so50283030pfb.6
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 22:39:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d83si37947966pfd.152.2016.11.23.22.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 22:39:11 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAO6d25t137680
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:39:11 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ws3ntxa8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:39:11 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 16:39:07 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E312E3578052
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:39:04 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAO6d4ak42008714
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:39:04 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAO6d3Jx001666
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:39:04 +1100
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support additional
 page copy routines.
References: <201611230331.FuGRxmmN%fengguang.wu@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 12:08:55 +0530
MIME-Version: 1.0
In-Reply-To: <201611230331.FuGRxmmN%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58368AFF.2050205@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Zi Yan <zi.yan@sent.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/23/2016 01:26 AM, kbuild test robot wrote:
> Hi Zi,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.9-rc6 next-20161122]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Zi-Yan/Parallel-hugepage-migration-optimization/20161123-022913
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>    include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>>> >> fs/f2fs/data.c:1938:26: sparse: not enough arguments for function migrate_page_copy
>    fs/f2fs/data.c: In function 'f2fs_migrate_page':
>    fs/f2fs/data.c:1938:2: error: too few arguments to function 'migrate_page_copy'
>      migrate_page_copy(newpage, page);

Yeah, this got missed which needs to be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
