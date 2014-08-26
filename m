Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E98E46B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 16:20:03 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y13so23232571pdi.17
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 13:20:03 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id vz10si5707013pbc.197.2014.08.26.13.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Aug 2014 13:20:02 -0700 (PDT)
Message-ID: <53FCEBF1.6030006@codeaurora.org>
Date: Tue, 26 Aug 2014 13:20:01 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [next:master 2145/2346] drivers/base/dma-mapping.c:294:2: error:
 implicit declaration of function 'dma_common_pages_remap'
References: <53fc8917.8odw5fgQ/XJIRB7e%fengguang.wu@intel.com>
In-Reply-To: <53fc8917.8odw5fgQ/XJIRB7e%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On 8/26/2014 6:18 AM, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   1c9e4561f3b2afffcda007eae9d0ddd25525f50e
> commit: fa44abcad042144651fa9cd0f698c7c40a59d60f [2145/2346] common: dma-mapping: introduce common remapping functions
> config: make ARCH=mn10300 asb2364_defconfig
> 
> All error/warnings:
> 
>    drivers/base/dma-mapping.c: In function 'dma_common_contiguous_remap':
>>> drivers/base/dma-mapping.c:294:2: error: implicit declaration of function 'dma_common_pages_remap' [-Werror=implicit-function-declaration]
>      ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
>      ^
>>> drivers/base/dma-mapping.c:294:6: warning: assignment makes pointer from integer without a cast
>      ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
>          ^
>    drivers/base/dma-mapping.c: At top level:
>>> drivers/base/dma-mapping.c:305:7: error: conflicting types for 'dma_common_pages_remap'
>     void *dma_common_pages_remap(struct page **pages, size_t size,
>           ^
>    drivers/base/dma-mapping.c:294:8: note: previous implicit declaration of 'dma_common_pages_remap' was here
>      ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
>            ^
>    cc1: some warnings being treated as errors
> 
> vim +/dma_common_pages_remap +294 drivers/base/dma-mapping.c
> 
>    288		if (!pages)
>    289			return NULL;
>    290	
>    291		for (i = 0, pfn = page_to_pfn(page); i < (size >> PAGE_SHIFT); i++)
>    292			pages[i] = pfn_to_page(pfn + i);
>    293	
>  > 294		ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
>    295	
>    296		kfree(pages);
>    297	
>    298		return ptr;
>    299	}
>    300	
>    301	/*
>    302	 * remaps an array of PAGE_SIZE pages into another vm_area
>    303	 * Cannot be used in non-sleeping contexts
>    304	 */
>  > 305	void *dma_common_pages_remap(struct page **pages, size_t size,
>    306				unsigned long vm_flags, pgprot_t prot,
>    307				const void *caller)
>    308	{
> 

I think this should work

----8<-----
