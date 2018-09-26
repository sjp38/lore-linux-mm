Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6D308E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:36:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s7-v6so5115773pgp.3
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:36:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4-v6sor615394pge.88.2018.09.26.05.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 05:36:04 -0700 (PDT)
Date: Wed, 26 Sep 2018 15:35:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [v11 PATCH 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180926123558.fiutdxeexeiqbndk@kshutemo-mobl1>
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 20, 2018 at 01:03:38AM +0800, Yang Shi wrote:
> 
> Yang Shi (3):
>       mm: mmap: zap pages with read mmap_sem in munmap
>       mm: unmap VM_HUGETLB mappings with optimized path
>       mm: unmap VM_PFNMAP mappings with optimized path
> 
>  mm/mmap.c | 50 +++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 39 insertions(+), 11 deletions(-)

The patchset looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
