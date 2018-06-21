Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07DA86B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 18:10:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so2140415pfn.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 15:10:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15-v6sor1437824pgt.87.2018.06.21.15.10.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 15:10:13 -0700 (PDT)
Date: Fri, 22 Jun 2018 01:10:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: register mm for khugepaged when merging vma for
 shmem
Message-ID: <20180621221008.r33hpd223kx2gv3a@kshutemo-mobl1>
References: <1529617247-126312-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529617247-126312-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 22, 2018 at 05:40:47AM +0800, Yang Shi wrote:
> When merging anonymous page vma, if the size of vam can fit in at least

s/vam/vma/

> one hugepage, the mm will be registered for khugepaged for collapsing
> THP in the future.
> 
> But, it skips shmem vma. Doing so for shmem too when merging vma in
> order to increase the odd to collapse hugepage by khugepaged.

Good catch. Thanks.

I think the fix incomplete. We shouldn't require vma->anon_vma for shmem,
only for anonymous mappings. We don't support file-private THPs.

> Also increase the count of shmem THP collapse. It looks missed before.

Separate patch, please.

-- 
 Kirill A. Shutemov
