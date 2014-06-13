Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 00FC26B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:52:03 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so2618003wib.5
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:52:03 -0700 (PDT)
Received: from mailrelay008.isp.belgacom.be (mailrelay008.isp.belgacom.be. [195.238.6.174])
        by mx.google.com with ESMTP id t7si2563609wiy.24.2014.06.13.09.52.02
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:52:02 -0700 (PDT)
Date: Fri, 13 Jun 2014 18:50:47 +0200
From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [mmotm:master 44/178] Warning(mm/page_alloc.c:2954): cannot
 understand function prototype: 'void * __meminit alloc_pages_exact_nid(int
 nid, size_t size, gfp_t gfp_mask) '
Message-Id: <20140613185047.c4af8711d0277c45587623c5@skynet.be>
In-Reply-To: <539a7429.Y+jT5tXL/lOF3DeD%fengguang.wu@intel.com>
References: <539a7429.Y+jT5tXL/lOF3DeD%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, 13 Jun 2014 11:46:49 +0800
kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
> commit: 4a35989d122d3ed0ead4132ed01e2fd2d8de74d7 [44/178] mm/page_alloc.c: add __meminit to alloc_pages_exact_nid()
> reproduce: make htmldocs
> 
> All warnings:
> 
>    Warning(lib/crc32.c:217): No description found for parameter 'tab)[256]'
>    Warning(lib/crc32.c:217): Excess function parameter 'tab' description in 'crc32_le_generic'
>    Warning(lib/crc32.c:300): No description found for parameter 'tab)[256]'
>    Warning(lib/crc32.c:300): Excess function parameter 'tab' description in 'crc32_be_generic'
>    Warning(lib/crc32.c): no structured comments found
>    Warning(mm/filemap.c:1054): No description found for parameter 'cache_gfp_mask'
>    Warning(mm/filemap.c:1054): No description found for parameter 'radix_gfp_mask'
>    Warning(mm/filemap.c:1054): Excess function parameter 'gfp_mask' description in 'pagecache_get_page'
> >> Warning(mm/page_alloc.c:2954): cannot understand function prototype: 'void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask) '

Hello Fengguang,

   There's no more htmldocs warning with 

void __meminit *alloc_pages_exact_nid()

but :

fgrep -re "__init *" | wc -l
79

fgrep -re "* __init" | wc -l
393

Looks more like a problem with make htmldocs or do I have to use another
 format ?

Regards,
Fabian

>    Warning(mm/page_alloc.c:6062): No description found for parameter 'pfn'
>    Warning(mm/page_alloc.c:6062): No description found for parameter 'mask'
>    Warning(mm/page_alloc.c:6062): Excess function parameter 'start_bitidx' description in 'get_pfnblock_flags_mask'
>    Warning(mm/page_alloc.c:6090): No description found for parameter 'pfn'
>    Warning(mm/page_alloc.c:6090): No description found for parameter 'mask'
>    Warning(mm/page_alloc.c:6090): Excess function parameter 'start_bitidx' description in 'set_pfnblock_flags_mask'
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
