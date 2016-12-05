Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7066B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:31:10 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so54027158wje.5
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:31:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si1685477wje.252.2016.12.05.01.31.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:31:09 -0800 (PST)
Date: Mon, 5 Dec 2016 10:31:01 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161205093100.GF30758@dhcp22.suse.cz>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz

On Mon 05-12-16 17:17:07, Huang Shijie wrote:
[...]
>    The failure is caused by:
>     1) kernel fails to allocate a gigantic page for the surplus case.
>        And the gather_surplus_pages() will return NULL in the end.
> 
>     2) The condition checks for some functions are wrong:
>         return_unused_surplus_pages()
>         nr_overcommit_hugepages_store()
>         hugetlb_overcommit_handler()

OK, so how is this any different from gigantic (1G) hugetlb pages on
x86_64? Do we need the same functionality or is it just 32MB not being
handled in the same way as 1G?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
