Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E64B5C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:43:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A5C21019
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:43:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A5C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B34C6B0294; Mon, 13 May 2019 08:43:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 065066B0295; Mon, 13 May 2019 08:43:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E93FE6B0296; Mon, 13 May 2019 08:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9FF6B0294
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:43:13 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m2so1429728ljj.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:43:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8PtUPN8e7qUv2UN0FXZGfwXYQHrkmndzYfGOtuSHB2s=;
        b=Z08DSzTrbHtE/HSA+Gg0MCRRRpP9hLNjEMuiHx1WsrJxYi58FTomxpNnZTKLqmxUDx
         cYMoAIsEaodyD2EsMzKdbTaTbK8P/wq325ybNHBmc3UeyPDK6yVNM2RdbHRZ84R5/JWj
         cQbUr0mPujSt3S+dTKhy/t8CEFFibENBxoCv3SyXOzuo5OxiDfonBzmevYqhD1cdEGY+
         5Ucm2cDJmlwBk2lJCLAjbEESambxjPN5eQscl2AV04d3cT/CgLQCaV3gckKUJdBqXJqt
         FCfj8FgqObLNfSj2LRTViN7yEHNi5NX/FxkSWB1hNNCNnKYYDxCXVNiXmGjzli6L3627
         lypA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAU7EjbYS+s/bJd2lZY9f+DIwPH4gea5/DHfgZPgullZRYDTWhP/
	py1lkI4C38zLDouQtuZ/x7HZXG/s98gCFJSEXJSelS9vzW0GtA1d51iTrxgxUWn17sRFY333vOU
	fdtGt+5mj3+y/daSvV+DIt4aVAu83f+p9jonaFhM2dGqO9sUGy9pX8OkQMcvTm5TIXA==
X-Received: by 2002:a2e:8583:: with SMTP id b3mr14396522lji.136.1557751392448;
        Mon, 13 May 2019 05:43:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhucoBlSctDkPyBoa78rqvFX4H9DrOQ21a/XbgOnf2qQbKlwoV/kpOuNc56NGBeRGRL3Ym
X-Received: by 2002:a2e:8583:: with SMTP id b3mr14396461lji.136.1557751391006;
        Mon, 13 May 2019 05:43:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557751391; cv=none;
        d=google.com; s=arc-20160816;
        b=FXT6e7SZFbSGketbOFmO8RiGAtQ9sCzvBI0mP7u2YkiXDg2rSj674vdlAeMs65N+4M
         PE8dY+D2Hdp+Qdx1l2TwwD0/UdFDi1BTJlpr5ll21I+hB5LzA7eW6nFj5ElQ1fJr22rq
         mHOR87ElFLt3Hy2qs7VybsI04CFP+PVaPd+UtbsIn8Ct7PY3EIXCgYqV0ds64E1hDn1H
         DoWC+ljIt2BCbH0klYNTKmk0XoJnlBwQrobpN5+GuS7noSGl9CJJxDkEBvqHmX8jQUd8
         N6kiya82+5oN8VbktzkCgAwWhefroz1MwhOflyElgBiCj+d/WPDfPSgFcTTcoi0n+RZB
         /6Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=8PtUPN8e7qUv2UN0FXZGfwXYQHrkmndzYfGOtuSHB2s=;
        b=0KG6umq8X3ihM0TkjsrhQr4ECoYxNoe/2LHzw6QgGANfk4g203LQpLQyPjaN9Rk7zn
         +8mKrqJLhZbUXCnPh7amdGLv0zcHRJstLMce6BoL/WL+7KNMWhx0JvT0OkahK+sCFY4L
         oouLLITR+Ct9PDMzhTci7TbgqGpHZ5prH+GN3jGrhWmftu0l3ivOcN+Qt0s6FlM/Tdav
         7mGcFfWH/D3J1vL7sxuY6wlDxxrmLMXcQUQp9BXSL5HqH5/qnZm6z9L/x5DU7XX5kzTp
         b8KW/ZaYBIc+aPsfbb/1Q77C4LF6sEURdAwcPsscicPbSpTDDOzEwJWs/Wqqivv1XZ0I
         HEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id p24si5286391lji.174.2019.05.13.05.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 05:43:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQAIQ-000695-3a; Mon, 13 May 2019 15:43:10 +0300
Subject: Re: [PATCH] mm: Introduce page_size()
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
References: <20190510181242.24580-1-willy@infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
Date: Mon, 13 May 2019 15:43:08 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190510181242.24580-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Matthew,

On 10.05.2019 21:12, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> It's unnecessarily hard to find out the size of a potentially large page.
> Replace 'PAGE_SIZE << compound_order(page)' with 'page_size(page)'.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  arch/arm/mm/flush.c                           | 3 +--
>  arch/arm64/mm/flush.c                         | 3 +--
>  arch/ia64/mm/init.c                           | 2 +-
>  drivers/staging/android/ion/ion_system_heap.c | 4 ++--
>  drivers/target/tcm_fc/tfc_io.c                | 3 +--
>  fs/io_uring.c                                 | 2 +-
>  include/linux/hugetlb.h                       | 2 +-
>  include/linux/mm.h                            | 9 +++++++++
>  lib/iov_iter.c                                | 2 +-
>  mm/kasan/common.c                             | 8 +++-----
>  mm/nommu.c                                    | 2 +-
>  mm/page_vma_mapped.c                          | 3 +--
>  mm/rmap.c                                     | 6 ++----
>  mm/slob.c                                     | 2 +-
>  mm/slub.c                                     | 4 ++--
>  net/xdp/xsk.c                                 | 2 +-
>  16 files changed, 29 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 58469623b015..c68a120de28b 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -207,8 +207,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
>  	 * coherent with the kernels mapping.
>  	 */
>  	if (!PageHighMem(page)) {
> -		size_t page_size = PAGE_SIZE << compound_order(page);
> -		__cpuc_flush_dcache_area(page_address(page), page_size);
> +		__cpuc_flush_dcache_area(page_address(page), page_size(page));
>  	} else {
>  		unsigned long i;
>  		if (cache_is_vipt_nonaliasing()) {
> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> index 5c9073bace83..280fdbc3bfa5 100644
> --- a/arch/arm64/mm/flush.c
> +++ b/arch/arm64/mm/flush.c
> @@ -67,8 +67,7 @@ void __sync_icache_dcache(pte_t pte)
>  	struct page *page = pte_page(pte);
>  
>  	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
> -		sync_icache_aliases(page_address(page),
> -				    PAGE_SIZE << compound_order(page));
> +		sync_icache_aliases(page_address(page), page_size(page));
>  }
>  EXPORT_SYMBOL_GPL(__sync_icache_dcache);
>  
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index d28e29103bdb..cc4061cd9899 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -63,7 +63,7 @@ __ia64_sync_icache_dcache (pte_t pte)
>  	if (test_bit(PG_arch_1, &page->flags))
>  		return;				/* i-cache is already coherent with d-cache */
>  
> -	flush_icache_range(addr, addr + (PAGE_SIZE << compound_order(page)));
> +	flush_icache_range(addr, addr + page_size(page));
>  	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
>  }
>  
> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> index aa8d8425be25..b83a1d16bd89 100644
> --- a/drivers/staging/android/ion/ion_system_heap.c
> +++ b/drivers/staging/android/ion/ion_system_heap.c
> @@ -120,7 +120,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
>  		if (!page)
>  			goto free_pages;
>  		list_add_tail(&page->lru, &pages);
> -		size_remaining -= PAGE_SIZE << compound_order(page);
> +		size_remaining -= page_size(page);
>  		max_order = compound_order(page);
>  		i++;
>  	}
> @@ -133,7 +133,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
>  
>  	sg = table->sgl;
>  	list_for_each_entry_safe(page, tmp_page, &pages, lru) {
> -		sg_set_page(sg, page, PAGE_SIZE << compound_order(page), 0);
> +		sg_set_page(sg, page, page_size(page), 0);
>  		sg = sg_next(sg);
>  		list_del(&page->lru);
>  	}
> diff --git a/drivers/target/tcm_fc/tfc_io.c b/drivers/target/tcm_fc/tfc_io.c
> index 1eb1f58e00e4..83c1ec65dbcc 100644
> --- a/drivers/target/tcm_fc/tfc_io.c
> +++ b/drivers/target/tcm_fc/tfc_io.c
> @@ -148,8 +148,7 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
>  					   page, off_in_page, tlen);
>  			fr_len(fp) += tlen;
>  			fp_skb(fp)->data_len += tlen;
> -			fp_skb(fp)->truesize +=
> -					PAGE_SIZE << compound_order(page);
> +			fp_skb(fp)->truesize += page_size(page);
>  		} else {
>  			BUG_ON(!page);
>  			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
> diff --git a/fs/io_uring.c b/fs/io_uring.c
> index fdc18321d70c..2c37da095517 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -2891,7 +2891,7 @@ static int io_uring_mmap(struct file *file, struct vm_area_struct *vma)
>  	}
>  
>  	page = virt_to_head_page(ptr);
> -	if (sz > (PAGE_SIZE << compound_order(page)))
> +	if (sz > page_size(page))
>  		return -EINVAL;
>  
>  	pfn = virt_to_phys(ptr) >> PAGE_SHIFT;
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index edf476c8cfb9..2e909072a41f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -472,7 +472,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  static inline struct hstate *page_hstate(struct page *page)
>  {
>  	VM_BUG_ON_PAGE(!PageHuge(page), page);
> -	return size_to_hstate(PAGE_SIZE << compound_order(page));
> +	return size_to_hstate(page_size(page));
>  }
>  
>  static inline unsigned hstate_index_to_shift(unsigned index)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..0208f77bab63 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -772,6 +772,15 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/*
> + * Returns the number of bytes in this potentially compound page.
> + * Must be called with the head page, not a tail page.
> + */
> +static inline unsigned long page_size(struct page *page)
> +{

Maybe we should underline commented head page limitation with VM_BUG_ON()?

Kirill

