Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD286B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 19:13:03 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so12201535pab.30
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 16:13:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vh3si31045645pbc.153.2014.12.01.16.13.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 16:13:02 -0800 (PST)
Date: Mon, 1 Dec 2014 16:13:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Remove the highmem zones' memmap in the highmem
 zone
Message-Id: <20141201161300.8d370b30b181e988065ec71d@linux-foundation.org>
In-Reply-To: <1417085194-17042-1-git-send-email-bocui107@gmail.com>
References: <1417085194-17042-1-git-send-email-bocui107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hongbo Zhong <bocui107@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Thu, 27 Nov 2014 18:46:34 +0800 Hongbo Zhong <bocui107@gmail.com> wrote:

> From: Zhong Hongbo <bocui107@gmail.com>
> 
> Since the commit 01cefaef40c4 ("mm: provide more accurate estimation
> of pages occupied by memmap") allocate the pages from lowmem for the
> highmem zones' memmap. So It is not need to reserver the memmap's for
> the highmem.

Looks right.

> A 2G DDR3 for the arm platform:
> On node 0 totalpages: 524288
> free_area_init_node: node 0, pgdat 80ccd380, node_mem_map 80d38000
>   DMA zone: 3568 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 456704 pages, LIFO batch:31
>   HighMem zone: 528 pages used for memmap
>   HighMem zone: 67584 pages, LIFO batch:15
> 
> On node 0 totalpages: 524288
> free_area_init_node: node 0, pgdat 80cd6f40, node_mem_map 80d42000
>   DMA zone: 3568 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 456704 pages, LIFO batch:31
>   HighMem zone: 67584 pages, LIFO batch:15

So nothing changed.  Maybe it would have if the machine had more
highmem.

I'm trying to work out what effect this patch actually has.  AFAICT it
provides more accurate values for zone->min_unmapped_pages and
zone->min_slab_pages on NUMA.  Anything else?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
