Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D349B6B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 15:43:33 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id yy13so87699441pab.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 12:43:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gk10si19450823pac.103.2016.02.01.12.43.33
        for <linux-mm@kvack.org>;
        Mon, 01 Feb 2016 12:43:33 -0800 (PST)
Date: Mon, 1 Feb 2016 15:43:35 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 4/6] dax: Use PAGE_CACHE_SIZE where appropriate
Message-ID: <20160201204335.GE2948@linux.intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
 <1454242795-18038-5-git-send-email-matthew.r.wilcox@intel.com>
 <20160201131019.GC29337@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160201131019.GC29337@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 01, 2016 at 03:10:19PM +0200, Kirill A. Shutemov wrote:
> On Sun, Jan 31, 2016 at 11:19:53PM +1100, Matthew Wilcox wrote:
> > We were a little sloppy about using PAGE_SIZE instead of PAGE_CACHE_SIZE.
> 
> PAGE_CACHE_SIZE is non-sense. It never had any meaning. At least in
> upstream. And only leads to confusion on border between vfs and mm.
> 
> We should just drop it.
> 
> I need to find time at some point to prepare patchset...

I argued in favour of this at last LSFMM and people were ... reluctant.
I think with your map_pages work, the PAGE_CACHE_SIZE idea now has no
potential performance win left.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
