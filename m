Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B788B6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 00:30:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z67so4834305pgb.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:30:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 33si1872404plq.10.2017.01.17.21.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 21:30:39 -0800 (PST)
Date: Tue, 17 Jan 2017 21:30:38 -0800
From: willy@bombadil.infradead.org
Subject: Re: [PATCH] mm: fix <linux/pagemap.h> stray kernel-doc notation
Message-ID: <20170118053038.GC18349@bombadil.infradead.org>
References: <b037e9a3-516c-ec02-6c8e-fa5479747ba6@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b037e9a3-516c-ec02-6c8e-fa5479747ba6@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Tue, Jan 17, 2017 at 06:10:51PM -0800, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Delete stray (second) function description in find_lock_page()
> kernel-doc notation.
> 
> Fixes: 2457aec63745e ("mm: non-atomically mark page accessed during page cache allocation where possible")
> 
> Note: scripts/kernel-doc just ignores the second function description.
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Reported-by: Matthew Wilcox <mawilcox@microsoft.com>

> Cc: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/pagemap.h |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- lnx-410-rc4.orig/include/linux/pagemap.h
> +++ lnx-410-rc4/include/linux/pagemap.h
> @@ -266,7 +266,6 @@ static inline struct page *find_get_page
>  
>  /**
>   * find_lock_page - locate, pin and lock a pagecache page
> - * pagecache_get_page - find and get a page reference
>   * @mapping: the address_space to search
>   * @offset: the page index
>   *
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
