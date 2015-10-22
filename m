Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B6E4D82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:09:10 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so71831637pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 17:09:10 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id gh4si16805722pbc.211.2015.10.21.17.09.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 17:09:10 -0700 (PDT)
Received: by pasz6 with SMTP id z6so68801307pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 17:09:09 -0700 (PDT)
Date: Thu, 22 Oct 2015 09:09:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: simplify reclaim path for MADV_FREE
Message-ID: <20151022000910.GF23631@bbox>
References: <20151021205417.GC9839@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151021205417.GC9839@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

n Wed, Oct 21, 2015 at 11:54:17PM +0300, Dan Carpenter wrote:
> Hello Minchan Kim,
> 
> The patch e4f28388eb72: "mm: simplify reclaim path for MADV_FREE"
> from Oct 21, 2015, leads to the following static checker warning:
> 
> 	mm/rmap.c:1469 try_to_unmap_one()
> 	warn: inconsistent indenting
> 
> mm/rmap.c
>   1459                  /*
>   1460                   * Store the swap location in the pte.
>   1461                   * See handle_pte_fault() ...
>   1462                   */
>   1463                  VM_BUG_ON_PAGE(!PageSwapCache(page), page);
>   1464                  if (swap_duplicate(entry) < 0) {
>   1465                          set_pte_at(mm, address, pte, pteval);
>   1466                          ret = SWAP_FAIL;
>   1467                          goto out_unmap;
>   1468                  }
>   1469                          if (!PageDirty(page))
>   1470                                  SetPageDirty(page);
> 
> My guess is that we can just remove the extra tabs.  It wasn't supposed
> to be before the "goto out_unmap;" was it?

Thanks for the report, Dan.
Thanks for the quick fix, Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
