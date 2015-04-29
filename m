Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCD96B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:04:31 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so19951291pdb.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:04:31 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id rr7si38038295pbc.173.2015.04.29.00.04.28
        for <linux-mm@kvack.org>;
        Wed, 29 Apr 2015 00:04:30 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [RFC v2 PATCH 0/5] hugetlbfs: add fallocate support
Date: Wed, 29 Apr 2015 15:04:02 +0800
Message-ID: <016801d0824a$ace5da80$06b18f80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, 'Hugh Dickins' <hughd@google.com>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Christoph Hellwig' <hch@infradead.org>

> 
> hugetlbfs is used today by applications that want a high degree of
> control over huge page usage.  Often, large hugetlbfs files are used
> to map a large number huge pages into the application processes.
> The applications know when page ranges within these large files will
> no longer be used, and ideally would like to release them back to
> the subpool or global pools for other uses.  The fallocate() system
> call provides an interface for preallocation and hole punching within
> files.  This patch set adds fallocate functionality to hugetlbfs.
> 
> RFC v2:
>   Addressed alignment and error handling issues noticed by Hillf Danton
>   New region_del() routine for region tracking/resv_map of ranges
>   Fixed several issues found during more extensive testing
>   Error handling in region_del() when kmalloc() fails stills needs
>         to be addressed
>   madvise remove support remains
> 
> Mike Kravetz (5):
>   hugetlbfs: truncate_hugepages() takes a range of pages
>   hugetlbfs: remove region_truncte() as region_del() can be used
>   hugetlbfs: New huge_add_to_page_cache helper routine
>   hugetlbfs: add hugetlbfs_fallocate()
>   mm: madvise allow remove operation for hugetlbfs
> 

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  fs/hugetlbfs/inode.c    | 169 ++++++++++++++++++++++++++++++++++++++++++++++--
>  include/linux/hugetlb.h |   8 ++-
>  mm/hugetlb.c            | 110 ++++++++++++++++++++++---------
>  mm/madvise.c            |   2 +-
>  4 files changed, 248 insertions(+), 41 deletions(-)
> 
> --
> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
