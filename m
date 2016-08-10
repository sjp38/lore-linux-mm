Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43C4E6B025E
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:14:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so89473513pfx.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:14:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id r27si49108161pfi.37.2016.08.10.09.14.22
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:14:22 -0700 (PDT)
Date: Wed, 10 Aug 2016 19:14:19 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2] rmap: Fix compound check logic in
 page_remove_file_rmap
Message-ID: <20160810161419.GB67522@black.fi.intel.com>
References: <1470838217-5889-1-git-send-email-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470838217-5889-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shijie.huang@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 10, 2016 at 03:10:17PM +0100, Steve Capper wrote:
> In page_remove_file_rmap(.) we have the following check:
>   VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
> 
> This is meant to check for either HugeTLB pages or THP when a compound
> page is passed in.
> 
> Unfortunately, if one disables CONFIG_TRANSPARENT_HUGEPAGE, then
> PageTransHuge(.) will always return false, provoking BUGs when one runs
> the libhugetlbfs test suite.
> 
> This patch replaces PageTransHuge(), with PageHead() which will work for
> both HugeTLB and THP.
> 
> Fixes: dd78fedde4b9 ("rmap: support file thp")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
