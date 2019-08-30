Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD140C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 14:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76EF02341B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 14:14:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="CO9IufDi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76EF02341B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 115AB6B0006; Fri, 30 Aug 2019 10:14:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C60B6B0008; Fri, 30 Aug 2019 10:14:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1EA96B000A; Fri, 30 Aug 2019 10:14:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id D08256B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 10:14:38 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6381D824CA35
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 14:14:38 +0000 (UTC)
X-FDA: 75879289836.11.birds10_458adaa46493d
X-HE-Tag: birds10_458adaa46493d
X-Filterd-Recvd-Size: 10163
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 14:14:37 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id o70so4747788pfg.5
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 07:14:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=GQjSOvbaapj7b1lMAgf5SR118C4E3gkJs2yq2l1Stv4=;
        b=CO9IufDiIWBBFWVq/OoN72/E+w27Lf2PiK+MbtGjm2ZrKSQf95I8oEHgGi7vHrwkLr
         G731ZAmg28Iv0+TE/2nZ840FNK5djXf6jO1rwwHN7953omIe0L8DDbLgOTkqHtMohlmd
         ubyBt64bC14KHBnAf5XlAnqGr3mA5jVj5HJFk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:in-reply-to:references:date
         :message-id:mime-version;
        bh=GQjSOvbaapj7b1lMAgf5SR118C4E3gkJs2yq2l1Stv4=;
        b=BvYsdfC8Fuw3kFws07hV6CmTAErf+wGOyVzuue9bAyzJbsn/jecct7Ahg9A5L0Wo+m
         d3Ha5qVHijfdIh7XwNGF+19Zve0fEwu+uv0zhTlZKj9ZGXq23h2A60h3B0Xl0DGNmwRM
         L6mMsfmj6MoCCtDej/YeRbFLU/A/wpG7ZJ+hJIWpBBipK19djCYcw2yjFMsnIGyYnP1l
         5Yh9sbOFiVZ3WdvZtgcyn0s9n5aMBQY27YVEVcayQVYONxcpypNhA1WjZuNgfAqk/RFP
         rR0/xunEmueTdmEb0D5en76aFZK52UFrOJ96/cWEoYN7Zg7jc1D8a+wq4+pSvAlF6rJt
         nnSQ==
X-Gm-Message-State: APjAAAXX04feowk+Dky0rbNUCPQbP8Yjz+kp/yduR545PF4L+2batqmW
	NYTPh8PdCwWs56XG7Mbckn4daQ==
X-Google-Smtp-Source: APXvYqy3+S6Dqbc3pwsOcQA/Iwof1bo7TCOO0pzdarafBh3pamLz1QVwXxYS1rtUoFL9YnX/8pRXcg==
X-Received: by 2002:aa7:8a48:: with SMTP id n8mr18631624pfa.143.1567174476689;
        Fri, 30 Aug 2019 07:14:36 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id g2sm7247374pfm.32.2019.08.30.07.14.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Aug 2019 07:14:35 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, dvyukov@google.com, christophe.leroy@c-s.fr
Cc: linuxppc-dev@lists.ozlabs.org, gor@linux.ibm.com
Subject: Re: [PATCH v5 1/5] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <20190830003821.10737-2-dja@axtens.net>
References: <20190830003821.10737-1-dja@axtens.net> <20190830003821.10737-2-dja@axtens.net>
Date: Sat, 31 Aug 2019 00:14:21 +1000
Message-ID: <871rx2viyq.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

> +static int kasan_depopulate_vmalloc_pte(pte_t *ptep, unsigned long addr,
> +					void *unused)
> +{
> +	unsigned long page;
> +
> +	page = (unsigned long)__va(pte_pfn(*ptep) << PAGE_SHIFT);
> +
> +	spin_lock(&init_mm.page_table_lock);
> +
> +	/*
> +	 * we want to catch bugs where we end up clearing a pte that wasn't
> +	 * set. This will unfortunately also fire if we are releasing a region
> +	 * where we had a failure allocating the shadow region.
> +	 */
> +	WARN_ON_ONCE(pte_none(*ptep));
> +
> +	pte_clear(&init_mm, addr, ptep);
> +	free_page(page);
> +	spin_unlock(&init_mm.page_table_lock);

It's just occurred to me that the free_page really needs to be guarded
by an 'if (likely(!pte_none(*pte))) {' - there won't be a page to free
if there's no pte.

I'll spin v6 on Monday.

Regards,
Daniel

> +
> +	return 0;
> +}
> +
> +/*
> + * Release the backing for the vmalloc region [start, end), which
> + * lies within the free region [free_region_start, free_region_end).
> + *
> + * This can be run lazily, long after the region was freed. It runs
> + * under vmap_area_lock, so it's not safe to interact with the vmalloc/vmap
> + * infrastructure.
> + */
> +void kasan_release_vmalloc(unsigned long start, unsigned long end,
> +			   unsigned long free_region_start,
> +			   unsigned long free_region_end)
> +{
> +	void *shadow_start, *shadow_end;
> +	unsigned long region_start, region_end;
> +
> +	/* we start with shadow entirely covered by this region */
> +	region_start = ALIGN(start, PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
> +	region_end = ALIGN_DOWN(end, PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
> +
> +	/*
> +	 * We don't want to extend the region we release to the entire free
> +	 * region, as the free region might cover huge chunks of vmalloc space
> +	 * where we never allocated anything. We just want to see if we can
> +	 * extend the [start, end) range: if start or end fall part way through
> +	 * a shadow page, we want to check if we can free that entire page.
> +	 */
> +
> +	free_region_start = ALIGN(free_region_start,
> +				  PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
> +
> +	if (start != region_start &&
> +	    free_region_start < region_start)
> +		region_start -= PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE;
> +
> +	free_region_end = ALIGN_DOWN(free_region_end,
> +				     PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE);
> +
> +	if (end != region_end &&
> +	    free_region_end > region_end)
> +		region_end += PAGE_SIZE * KASAN_SHADOW_SCALE_SIZE;
> +
> +	shadow_start = kasan_mem_to_shadow((void *)region_start);
> +	shadow_end = kasan_mem_to_shadow((void *)region_end);
> +
> +	if (shadow_end > shadow_start)
> +		apply_to_page_range(&init_mm, (unsigned long)shadow_start,
> +				    (unsigned long)(shadow_end - shadow_start),
> +				    kasan_depopulate_vmalloc_pte, NULL);
> +}
> +#endif
> diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
> index 36c645939bc9..2d97efd4954f 100644
> --- a/mm/kasan/generic_report.c
> +++ b/mm/kasan/generic_report.c
> @@ -86,6 +86,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
>  	case KASAN_ALLOCA_RIGHT:
>  		bug_type = "alloca-out-of-bounds";
>  		break;
> +	case KASAN_VMALLOC_INVALID:
> +		bug_type = "vmalloc-out-of-bounds";
> +		break;
>  	}
>  
>  	return bug_type;
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 35cff6bbb716..3a083274628e 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -25,6 +25,7 @@
>  #endif
>  
>  #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
> +#define KASAN_VMALLOC_INVALID   0xF9  /* unallocated space in vmapped page */
>  
>  /*
>   * Stack redzone shadow values
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index b8101030f79e..bf806566cad0 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -690,8 +690,19 @@ merge_or_add_vmap_area(struct vmap_area *va,
>  	struct list_head *next;
>  	struct rb_node **link;
>  	struct rb_node *parent;
> +	unsigned long orig_start, orig_end;
>  	bool merged = false;
>  
> +	/*
> +	 * To manage KASAN vmalloc memory usage, we use this opportunity to
> +	 * clean up the shadow memory allocated to back this allocation.
> +	 * Because a vmalloc shadow page covers several pages, the start or end
> +	 * of an allocation might not align with a shadow page. Use the merging
> +	 * opportunities to try to extend the region we can release.
> +	 */
> +	orig_start = va->va_start;
> +	orig_end = va->va_end;
> +
>  	/*
>  	 * Find a place in the tree where VA potentially will be
>  	 * inserted, unless it is merged with its sibling/siblings.
> @@ -741,6 +752,10 @@ merge_or_add_vmap_area(struct vmap_area *va,
>  		if (sibling->va_end == va->va_start) {
>  			sibling->va_end = va->va_end;
>  
> +			kasan_release_vmalloc(orig_start, orig_end,
> +					      sibling->va_start,
> +					      sibling->va_end);
> +
>  			/* Check and update the tree if needed. */
>  			augment_tree_propagate_from(sibling);
>  
> @@ -754,6 +769,8 @@ merge_or_add_vmap_area(struct vmap_area *va,
>  	}
>  
>  insert:
> +	kasan_release_vmalloc(orig_start, orig_end, va->va_start, va->va_end);
> +
>  	if (!merged) {
>  		link_va(va, root, parent, link, head);
>  		augment_tree_propagate_from(va);
> @@ -2068,6 +2085,22 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
>  
>  	setup_vmalloc_vm(area, va, flags, caller);
>  
> +	/*
> +	 * For KASAN, if we are in vmalloc space, we need to cover the shadow
> +	 * area with real memory. If we come here through VM_ALLOC, this is
> +	 * done by a higher level function that has access to the true size,
> +	 * which might not be a full page.
> +	 *
> +	 * We assume module space comes via VM_ALLOC path.
> +	 */
> +	if (is_vmalloc_addr(area->addr) && !(area->flags & VM_ALLOC)) {
> +		if (kasan_populate_vmalloc(area->size, area)) {
> +			unmap_vmap_area(va);
> +			kfree(area);
> +			return NULL;
> +		}
> +	}
> +
>  	return area;
>  }
>  
> @@ -2245,6 +2278,9 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>  	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
>  
> +	if (area->flags & VM_KASAN)
> +		kasan_poison_vmalloc(area->addr, area->size);
> +
>  	vm_remove_mappings(area, deallocate_pages);
>  
>  	if (deallocate_pages) {
> @@ -2495,6 +2531,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  	if (!addr)
>  		return NULL;
>  
> +	if (kasan_populate_vmalloc(real_size, area))
> +		return NULL;
> +
>  	/*
>  	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
>  	 * flag. It means that vm_struct is not fully initialized.
> @@ -3349,10 +3388,14 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
>  	spin_unlock(&vmap_area_lock);
>  
>  	/* insert all vm's */
> -	for (area = 0; area < nr_vms; area++)
> +	for (area = 0; area < nr_vms; area++) {
>  		setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
>  				 pcpu_get_vm_areas);
>  
> +		/* assume success here */
> +		kasan_populate_vmalloc(sizes[area], vms[area]);
> +	}
> +
>  	kfree(vas);
>  	return vms;
>  
> -- 
> 2.20.1

