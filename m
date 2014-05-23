Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 47ABD6B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 16:55:14 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id c1so1194993igq.7
        for <linux-mm@kvack.org>; Fri, 23 May 2014 13:55:14 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id l9si5094209igv.4.2014.05.23.13.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 13:55:13 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id rd18so5444283iec.24
        for <linux-mm@kvack.org>; Fri, 23 May 2014 13:55:13 -0700 (PDT)
Date: Fri, 23 May 2014 13:55:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/madvise: fix WILLNEED on SHM/ANON to actually do
 something
In-Reply-To: <1400847135-22291-1-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.DEB.2.02.1405231353080.13205@chino.kir.corp.google.com>
References: <1400847135-22291-1-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Fri, 23 May 2014, David Herrmann wrote:

> diff --git a/mm/madvise.c b/mm/madvise.c
> index 539eeb9..a402f8f 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -195,7 +195,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
>  	for (; start < end; start += PAGE_SIZE) {
>  		index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>  
> -		page = find_get_page(mapping, index);
> +		page = find_get_entry(mapping, index);
>  		if (!radix_tree_exceptional_entry(page)) {
>  			if (page)
>  				page_cache_release(page);

This is already in -mm from Johannes, see 
http://marc.info/?l=linux-kernel&m=139998616712729.  Check out 
http://www.ozlabs.org/~akpm/mmotm/ for this kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
