Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D50C96B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 12:41:02 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so12169823pdb.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 09:41:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fu16si40719313pdb.173.2015.06.24.09.41.01
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 09:41:01 -0700 (PDT)
Date: Wed, 24 Jun 2015 12:40:59 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] mm: make GUP handle pfn mapping unless FOLL_GET is
 requested
Message-ID: <20150624164059.GF1971@linux.intel.com>
References: <1435141503-100635-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435141503-100635-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org

On Wed, Jun 24, 2015 at 01:25:03PM +0300, Kirill A. Shutemov wrote:
> With DAX, pfn mapping becoming more common. The patch adjusts GUP code
> to cover pfn mapping for cases when we don't need struct page to
> proceed.
> 
> To make it possible, let's change follow_page() code to return -EEXIST
> error code if proper page table entry exists, but no corresponding
> struct page. __get_user_page() would ignore the error code and move to
> the next page frame.
> 
> The immediate effect of the change is working MAP_POPULATE and mlock()
> on DAX mappings.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Toshi Kani <toshi.kani@hp.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>

Acked-by: Matthew Wilcox <willy@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
