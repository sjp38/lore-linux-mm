Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9808F6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:10:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so4338162plv.0
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 15:10:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8-v6sor2839319plt.136.2018.06.22.15.10.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 15:10:41 -0700 (PDT)
Date: Sat, 23 Jun 2018 01:10:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [v3 PATCH] mm: thp: register mm for khugepaged when merging vma
 for shmem
Message-ID: <20180622221036.va5vmdcnxny3fhxu@kshutemo-mobl1>
References: <1529697791-6950-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529697791-6950-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jun 23, 2018 at 04:03:11AM +0800, Yang Shi wrote:
> When merging anonymous page vma, if the size of vma can fit in at least
> one hugepage, the mm will be registered for khugepaged for collapsing
> THP in the future.
> 
> But, it skips shmem vma. Doing so for shmem too, but not file-private
> mapping, when merging vma in order to increase the odd to collapse
> hugepage by khugepaged.
> 
> hugepage_vma_check() sounds like a good fit to do the check. And, moved
> the definition of it before khugepaged_enter_vma_merge() to suppress
> build error.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
