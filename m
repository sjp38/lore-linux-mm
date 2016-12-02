Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 567286B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:06:01 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so4630527wjc.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:06:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lt8si5365750wjb.107.2016.12.02.06.06.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 06:06:00 -0800 (PST)
Date: Fri, 2 Dec 2016 15:05:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2 0/6] mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161202140556.GN6830@dhcp22.suse.cz>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon 14-11-16 15:07:33, Huang Shijie wrote:
> (1) Background
>    For the arm64, the hugetlb page size can be 32M (PMD + Contiguous bit).
>    In the 4K page environment, the max page order is 10 (max_order - 1),
>    so 32M page is the gigantic page.    
> 
>    The arm64 MMU supports a Contiguous bit which is a hint that the TTE
>    is one of a set of contiguous entries which can be cached in a single
>    TLB entry.  Please refer to the arm64v8 mannul :
>        DDI0487A_f_armv8_arm.pdf (in page D4-1811)
> 
> (2) The bug   
>    After I tested the libhugetlbfs, I found the test case "counter.sh"
>    will fail with the gigantic page (32M page in arm64 board).
> 
>    This patch set adds support for gigantic surplus hugetlb pages,
>    allowing the counter.sh unit test to pass.   

Andrew, I have noticed that this patchset is sitting in the mmotm tree
already. I have to say I am not really happy about the changes it is
introducing. It is making a confused code base even more so. I have
already commented on respective patches but in general I think it needs
a deeper thought before it can be merged.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
