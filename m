Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD9AC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:07:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F1A2086D
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:07:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F1A2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08D976B0003; Thu,  8 Aug 2019 03:07:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03E706B0006; Thu,  8 Aug 2019 03:07:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6E716B0007; Thu,  8 Aug 2019 03:07:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 984B36B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:07:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f16so44576028wrw.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:07:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Ty0lHwkJORRV3g4Qm1PzmY9XHSFN3x1ox0hXcob6AVQ=;
        b=l2LBGuQfyKQ8NS1LRI7/ujDJI5sfyRENK8aDeTbGnoiou368VTOUGDzdCHBS4rDAxx
         ymJidxCvM6xMx5usi2W0Pgp8CMjcBKndQ/j8gTgQbPTepxoAJZqFykIfTRGgqAIFOLvy
         94zwNDI7oYG4KBIxy/uJF8t+NGNH9WNdpZzW70p2wxxZnwWWCp92l3/EKkVh/9q8uB0D
         TBqQFP+3GHv3DJV5O3qzaEjRpLU9GlooBSJUMFeeenXRAksAh6puduTz+KVjcB2s3r7N
         2Ak0nlsVI4Wsq0+YIhy4i8l3xQ6UDphaxd5t6YGP43ME72GEbhq8osPVsTmbQRelm3QT
         9afw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUYZdwINB1dlwKLFuJ5Mbr+Re54tNk9dleCShC84jhpH4r7sfYL
	vKAqw4+c8LzufA6dTrYvFThl3FKpq4KeTi5PCE+nW4jPCs3465cBsJC7L9xX/tBDSnaQTm/vzk7
	4SQNfmnWAIcIFhMSss3mNJkoIX7bpPEDk9M1r0/L0AKhYVxMLCjJcFw+jkBbgNEtH1Q==
X-Received: by 2002:a1c:7503:: with SMTP id o3mr2412773wmc.170.1565248025926;
        Thu, 08 Aug 2019 00:07:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7z0qWWwL5pMWlpNrDuUjdjUxPUc/nei5leV8xK6rdBNaQk4xBK+jUygnKwjqdGYKEnnHM
X-Received: by 2002:a1c:7503:: with SMTP id o3mr2412645wmc.170.1565248024447;
        Thu, 08 Aug 2019 00:07:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565248024; cv=none;
        d=google.com; s=arc-20160816;
        b=kd5xfydo6/o4bauqS1N/1bX7dmoKY0OKDS4fLpR7cBPlK/Y7AoqCvZjd/AOFATLiQt
         WrXvwn+wOtytEuUoGEqTAw+wgG00kmgW7ogWKwq4vaG8d+ePpwPAjPWqSZtf0Hxvb545
         LU2I8tyYNOy22R7JU74vJQKpkGPpVLw/1NmD4kduNUeiZSv+oYx98+NcbGeuMMzbk9v/
         t5lrGj9BN8wjxl8KBGbh89VVpAOJIOubBFuYmC1xFChizCfMOGtuACAIrDydCEy+r8yf
         6kF3vKO4lS+oEZRK6l4sUdrGW2yfu5Y/AVey4kuGqDQkr3MGeVJDj1SToQgqecQ8aU1A
         aOoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Ty0lHwkJORRV3g4Qm1PzmY9XHSFN3x1ox0hXcob6AVQ=;
        b=TWuxruJ2wuMZOYXssBhPSGVInyCnm4E1U/K4RoeQ0bgIpjlJNcCZ0Yidt88wiU6xY8
         GeGSFVzjgbkMsMeB5Ju/OhKQZcKmFq/bhHR+sdLJeYC4tgOl4o6llmTrZKgs+ZXSQq/B
         oVtLpKbcGTc5lujYkT2gcYrhnMxOXx7UjrpBGK6yK0U4q2Vbd47zeiIN1pSZSJTMl/Vk
         +NKbvL+/rYWmQY1YbySJV5ZtqsM5q6ZMcPqLYQM2GS9kRKLdN6U66vQWkuhdVR66cHLU
         L6iti2nDt29+vmB9jTLQ7D/LLoYDpyak2LbCDhzSrV3lCalWiszuYe/ZbBaCnw66SfJ9
         Rd5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s24si88666065wrb.65.2019.08.08.00.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:07:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3426E68B02; Thu,  8 Aug 2019 09:07:02 +0200 (CEST)
Date: Thu, 8 Aug 2019 09:07:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Jason Gunthorpe <jgg@mellanox.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] nouveau/hmm: map pages after migration
Message-ID: <20190808070701.GC29382@lst.de>
References: <20190807150214.3629-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190807150214.3629-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 08:02:14AM -0700, Ralph Campbell wrote:
> When memory is migrated to the GPU it is likely to be accessed by GPU
> code soon afterwards. Instead of waiting for a GPU fault, map the
> migrated memory into the GPU page tables with the same access permissions
> as the source CPU page table entries. This preserves copy on write
> semantics.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> ---
> 
> This patch is based on top of Christoph Hellwig's 9 patch series
> https://lore.kernel.org/linux-mm/20190729234611.GC7171@redhat.com/T/#u
> "turn the hmm migrate_vma upside down" but without patch 9
> "mm: remove the unused MIGRATE_PFN_WRITE" and adds a use for the flag.

This looks useful.  I've already dropped that patch for the pending
resend.

>  static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm,
> -		struct vm_area_struct *vma, unsigned long addr,
> -		unsigned long src, dma_addr_t *dma_addr)
> +		struct vm_area_struct *vma, unsigned long src,
> +		dma_addr_t *dma_addr, u64 *pfn)

I'll pick up the removal of the not needed addr argument for the patch
introducing nouveau_dmem_migrate_copy_one, thanks,

>  static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
> -		struct nouveau_drm *drm, dma_addr_t *dma_addrs)
> +		struct nouveau_drm *drm, dma_addr_t *dma_addrs, u64 *pfns)
>  {
>  	struct nouveau_fence *fence;
>  	unsigned long addr = args->start, nr_dma = 0, i;
>  
>  	for (i = 0; addr < args->end; i++) {
>  		args->dst[i] = nouveau_dmem_migrate_copy_one(drm, args->vma,
> -				addr, args->src[i], &dma_addrs[nr_dma]);
> +				args->src[i], &dma_addrs[nr_dma], &pfns[i]);

Nit: I find the &pfns[i] way to pass the argument a little weird to read.
Why not "pfns + i"?

> +u64 *
> +nouveau_pfns_alloc(unsigned long npages)
> +{
> +	struct nouveau_pfnmap_args *args;
> +
> +	args = kzalloc(sizeof(*args) + npages * sizeof(args->p.phys[0]),

Can we use struct_size here?

> +	int ret;
> +
> +	if (!svm)
> +		return;
> +
> +	mutex_lock(&svm->mutex);
> +	svmm = nouveau_find_svmm(svm, mm);
> +	if (!svmm) {
> +		mutex_unlock(&svm->mutex);
> +		return;
> +	}
> +	mutex_unlock(&svm->mutex);

Given that nouveau_find_svmm doesn't take any kind of reference, what
gurantees svmm doesn't go away after dropping the lock?

> @@ -44,5 +49,19 @@ static inline int nouveau_svmm_bind(struct drm_device *device, void *p,
>  {
>  	return -ENOSYS;
>  }
> +
> +u64 *nouveau_pfns_alloc(unsigned long npages)
> +{
> +	return NULL;
> +}
> +
> +void nouveau_pfns_free(u64 *pfns)
> +{
> +}
> +
> +void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
> +		      unsigned long addr, u64 *pfns, unsigned long npages)
> +{
> +}
>  #endif /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */

nouveau_dmem.c and nouveau_svm.c are both built conditional on
CONFIG_DRM_NOUVEAU_SVM, so there is no need for stubs here.

