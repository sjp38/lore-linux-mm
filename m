Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFEFC6B0253
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 05:55:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e128so3072830wmg.1
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 02:55:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o49sor5225710edo.16.2017.12.10.02.55.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Dec 2017 02:55:27 -0800 (PST)
Date: Sun, 10 Dec 2017 13:55:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3] mm: Add unmap_mapping_pages
Message-ID: <20171210105524.k2jxa32dcmotmnzd@node.shutemov.name>
References: <20171205154453.GD28760@bombadil.infradead.org>
 <20171206142627.GD32044@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206142627.GD32044@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Dec 06, 2017 at 06:26:27AM -0800, Matthew Wilcox wrote:
> v3:
>  - Fix compilation
>    (I forgot to git commit --amend)
>  - Added Ross' Reviewed-by
> v2:
>  - Fix inverted mask in dax.c
>  - Pass 'false' instead of '0' for 'only_cows'
>  - nommu definition
> 
> --- 8< ---
> 
> From df142c51e111f7c386f594d5443530ea17abba5f Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Tue, 5 Dec 2017 00:15:54 -0500
> Subject: [PATCH v3] mm: Add unmap_mapping_pages
> 
> Several users of unmap_mapping_range() would prefer to express their
> range in pages rather than bytes.  Unfortuately, on a 32-bit kernel,
> you have to remember to cast your page number to a 64-bit type before
> shifting it, and four places in the current tree didn't remember to
> do that.  That's a sign of a bad interface.
> 
> Conveniently, unmap_mapping_range() actually converts from bytes into
> pages, so hoist the guts of unmap_mapping_range() into a new function
> unmap_mapping_pages() and convert the callers which want to use pages.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Reported-by: "zhangyi (F)" <yi.zhang@huawei.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
