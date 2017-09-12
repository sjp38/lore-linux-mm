Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD3D6B0310
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 02:05:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x78so19045947pff.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 23:05:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l3sor4059495pld.39.2017.09.11.23.05.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 23:05:00 -0700 (PDT)
Date: Tue, 12 Sep 2017 15:04:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 5/5] mm:swap: skip swapcache for swapin of synchronous
 device
Message-ID: <20170912060456.GA703@jagdpanzerIV.localdomain>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
 <1505183833-4739-5-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505183833-4739-5-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>

On (09/12/17 11:37), Minchan Kim wrote:
> +		} else {
> +			/* skip swapcache */
> +			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);

what if alloc_page_vma() fails?

> +			__SetPageLocked(page);
> +			__SetPageSwapBacked(page);
> +			set_page_private(page, entry.val);
> +			lru_cache_add_anon(page);
> +			swap_readpage(page, true);
> +		}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
