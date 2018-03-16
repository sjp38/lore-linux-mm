Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 963256B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:05:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z11-v6so5125446plo.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 03:05:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 98-v6si5913698pls.244.2018.03.16.03.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 03:05:14 -0700 (PDT)
Date: Fri, 16 Mar 2018 13:05:10 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm/khugepaged: Convert VM_BUG_ON() to collapse fail
Message-ID: <20180316100510.gedh6svgemb5jrmj@black.fi.intel.com>
References: <20180315152353.27989-1-kirill.shutemov@linux.intel.com>
 <20180315160453.dff17cfe3dca056dabc98b9e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315160453.dff17cfe3dca056dabc98b9e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 15, 2018 at 11:04:53PM +0000, Andrew Morton wrote:
> On Thu, 15 Mar 2018 18:23:53 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > khugepaged is not yet able to convert PTE-mapped huge pages back to PMD
> > mapped. We do not collapse such pages. See check khugepaged_scan_pmd().
> > 
> > But if between khugepaged_scan_pmd() and __collapse_huge_page_isolate()
> > somebody managed to instantiate THP in the range and then split the PMD
> > back to PTEs we would have a problem -- VM_BUG_ON_PAGE(PageCompound(page))
> > will get triggered.
> > 
> > It's possible since we drop mmap_sem during collapse to re-take for
> > write.
> > 
> > Replace the VM_BUG_ON() with graceful collapse fail.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Fixes: b1caa957ae6d ("khugepaged: ignore pmd tables with THP mapped with ptes")
> 
> Jan 2016.  Do we need a cc:stable?

Yes, please. I forgot to put it.

-- 
 Kirill A. Shutemov
