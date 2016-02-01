Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5062D6B0254
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 15:43:57 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so87843680pac.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 12:43:57 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y15si48351325pfi.232.2016.02.01.12.43.56
        for <linux-mm@kvack.org>;
        Mon, 01 Feb 2016 12:43:56 -0800 (PST)
Date: Mon, 1 Feb 2016 15:44:01 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] mm: Use linear_page_index() in do_fault()
Message-ID: <20160201204401.GF2948@linux.intel.com>
References: <1454242401-17005-1-git-send-email-matthew.r.wilcox@intel.com>
 <20160201130638.GB29337@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160201130638.GB29337@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 01, 2016 at 03:06:38PM +0200, Kirill A. Shutemov wrote:
> On Sun, Jan 31, 2016 at 11:13:21PM +1100, Matthew Wilcox wrote:
> > do_fault assumes that PAGE_SIZE is the same as PAGE_CACHE_SIZE.
> > Use linear_page_index() to calculate pgoff in the correct units.
> > 
> > Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> 'linear' part of helper name is not relevant any more since we've dropped
> non-linear mappings. Probably, we should rename helpers.

Ah, that's what it was named for.  Yes, probably.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
