Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33F57C31E44
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 02:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE7322133D
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 02:21:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Wrpbd+ve"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE7322133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 226016B0003; Fri, 14 Jun 2019 22:21:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D76B6B0005; Fri, 14 Jun 2019 22:21:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09E288E0001; Fri, 14 Jun 2019 22:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D67FD6B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 22:21:58 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y205so4529238ywy.19
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 19:21:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=WJzwzCgvzE/hvQi9PR+CecpM2nsoSUilOVqb8rOZbEc=;
        b=uJ59x7D9B1BXoQAw1v5GuvG0grp4xMTj6zfBCWZFbQoJ0HHCoTT5hSu8xKqK1vw6tC
         MiXUfFM18W1e1VL2Lx58bf7Ys3mExmkNh21qFTGpk0EMoBwEmFjWIHf1su+ZyQLqRP0I
         n5zzFlxnbry9j+9uFVBSbURDBruG0vyKtNh/VRwuQLfyuZjD5xO0a4PEsUTakAXqT1nQ
         TzxjpOjWCqs/0itwm5yWZ559cQajBT0d6+OzaBsqyHdyen2wOoP/2l1mjBC1mpYMuDnd
         T5oUeUguE0GwHa3wvyUS0S+K1NNHW+gUbSb7Qm7weVOwAgBO4rKHNcurtGLfccXzhMX+
         hDCw==
X-Gm-Message-State: APjAAAVqYiZz/zEUAmBIiBU0ijLjxuevQLHUa4gKOtRR+cPJi468byDR
	hb3kPM7N1hLMdYpArgdL7WrQ3a/jp0dUKDUoZXxFyFg8/MEEwgGcKvLsObQA+uZonjdHXKZjoWj
	C4xDQHV4p1eSXsq52rnlz13GcmDpUM2NUB+egrWIS8INhY/dW8dsD4nLzS6bqAXrY4g==
X-Received: by 2002:a25:b44a:: with SMTP id c10mr52498929ybg.26.1560565318523;
        Fri, 14 Jun 2019 19:21:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmJHQAT46Vxgey99VqYAkkIg3cUrt0erBk90QDEa4peJ4oWEh1czllohHbZex6rNf6rLqh
X-Received: by 2002:a25:b44a:: with SMTP id c10mr52498896ybg.26.1560565317145;
        Fri, 14 Jun 2019 19:21:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560565317; cv=none;
        d=google.com; s=arc-20160816;
        b=GDMgse78JUbBgIk/g643UCXbOowsaudCQhfx+W3Lt1yjH1o9xtK3OrrMvRoTmbMtAr
         kIBYI1UI81X4fcJ80uI47BCn2/IhFA1SRfvtWrbqtMgu+3RIofnSaQ3TUuHdxnRPC3sd
         3HrSpytwAh0a++ioRhbZQfk4AeMhYxiG4uX23HmUxwBm7coFa9rUCX6Gt9VLEhHJ6sm/
         ltZQsrTmjSyXuvFWghLiPHX+CkrDZy2bS2DBYpKglD1MabffPWYEQg5Ot5Gj+9Dvmbgg
         WCrdFqCNpfWX13bAuOHUSX7D7yhZGXYh3nKdO74bqkaKBIaHpM2LGHLh7J1dbxs1JlLL
         l6mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=WJzwzCgvzE/hvQi9PR+CecpM2nsoSUilOVqb8rOZbEc=;
        b=KjBijZzFKQ2qqOAW1OASv1Z4QHygUE8zU67QM9Qxw49QKmE+PrJClW6VbvLIIvjajK
         aMuKfwqQxFteM7fMZaIfAELgOzIK51Ry4DH86xsD4dwGQgeOIXC7qAbHeCDfjgn32oT+
         Yj4ZL9FrMpk9VzNjvw9EU/uup/Ji+8ST6O07OabITK1946a55U5qd53wfU5LIf0jNylL
         6cqRLU3lCZI12Hd+6IaWqTCNKpScYE44QMVgG13Qsp2DfmQk40PwBw+f3s9WAGqHn8Z3
         sM5JpChmftxK3FN7u+Vsrkbma1mlnIoAsdh4i+CJ6uHzHnRaQ8PEb8i7GPrTEUw2ZFbA
         vKAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Wrpbd+ve;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 206si1483846ybo.413.2019.06.14.19.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 19:21:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Wrpbd+ve;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d0456440000>; Fri, 14 Jun 2019 19:21:56 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 14 Jun 2019 19:21:56 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 14 Jun 2019 19:21:56 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 15 Jun
 2019 02:21:54 +0000
Subject: Re: [PATCH 06/22] mm: factor out a devm_request_free_mem_region
 helper
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-nvdimm@lists.01.org>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-7-hch@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <56c130b1-5ed9-7e75-41d9-c61e73874cb8@nvidia.com>
Date: Fri, 14 Jun 2019 19:21:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-7-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560565316; bh=WJzwzCgvzE/hvQi9PR+CecpM2nsoSUilOVqb8rOZbEc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Wrpbd+vezebbWZ643VNy/Em49DwFVtPOvBanIqtBVbnxqePGaXvVsDLbnAFeQ20Bo
	 FUbAkEZRJYA2iKjB7l+eplhrGf6FCEkDOHbNl+hoUZECH5+53q8HpY3b5RbAmqDlWm
	 /1m9iCBKEzDPqT0pIUqrMypRQQMkcz/2C+EisOEgSsT3kXfk1B/H+WmpIwjWravkTc
	 caFgA8nKnmpZdevI4CMQopIhREn9Bn3g2CbbmwGET/h0hd2ubIwQXJ4lJl4YufHmbY
	 sUqOtZBR/dpBQn0gzhwDZMISrFbh7eYgN+0+MFsSBlj1ulb5+W9/UcfRu8xtGgQ2R4
	 EnU769sA9R1gA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> Keep the physical address allocation that hmm_add_device does with the
> rest of the resource code, and allow future reuse of it without the hmm
> wrapper.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/ioport.h |  2 ++
>  kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
>  mm/hmm.c               | 33 ++++-----------------------------
>  3 files changed, 45 insertions(+), 29 deletions(-)

Some trivial typos noted below, but this accurately moves the code
into a helper routine, looks good.

Reviewed-by: John Hubbard <jhubbard@nvidia.com> 


> 
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index da0ebaec25f0..76a33ae3bf6c 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -286,6 +286,8 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
>         return (r1->start <= r2->end && r1->end >= r2->start);
>  }
>  
> +struct resource *devm_request_free_mem_region(struct device *dev,
> +		struct resource *base, unsigned long size);
>  
>  #endif /* __ASSEMBLY__ */
>  #endif	/* _LINUX_IOPORT_H */
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 158f04ec1d4f..99c58134ed1c 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1628,6 +1628,45 @@ void resource_list_free(struct list_head *head)
>  }
>  EXPORT_SYMBOL(resource_list_free);
>  
> +#ifdef CONFIG_DEVICE_PRIVATE
> +/**
> + * devm_request_free_mem_region - find free region for device private memory
> + *
> + * @dev: device struct to bind the resource too

                                               "to"

> + * @size: size in bytes of the device memory to add
> + * @base: resource tree to look in
> + *
> + * This function tries to find an empty range of physical address big enough to
> + * contain the new resource, so that it can later be hotpluged as ZONE_DEVICE

                                                        "hotplugged"

> + * memory, which in turn allocates struct pages.
> + */
> +struct resource *devm_request_free_mem_region(struct device *dev,
> +		struct resource *base, unsigned long size)
> +{
> +	resource_size_t end, addr;
> +	struct resource *res;
> +
> +	size = ALIGN(size, 1UL << PA_SECTION_SHIFT);
> +	end = min_t(unsigned long, base->end, (1UL << MAX_PHYSMEM_BITS) - 1);
> +	addr = end - size + 1UL;
> +
> +	for (; addr > size && addr >= base->start; addr -= size) {
> +		if (region_intersects(addr, size, 0, IORES_DESC_NONE) !=
> +				REGION_DISJOINT)
> +			continue;
> +
> +		res = devm_request_mem_region(dev, addr, size, dev_name(dev));
> +		if (!res)
> +			return ERR_PTR(-ENOMEM);
> +		res->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
> +		return res;
> +	}
> +
> +	return ERR_PTR(-ERANGE);
> +}
> +EXPORT_SYMBOL_GPL(devm_request_free_mem_region);
> +#endif /* CONFIG_DEVICE_PRIVATE */
> +
>  static int __init strict_iomem(char *str)
>  {
>  	if (strstr(str, "relaxed"))
> diff --git a/mm/hmm.c b/mm/hmm.c
> index e1dc98407e7b..13a16faf0a77 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -26,8 +26,6 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/memory_hotplug.h>
>  
> -#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
> -
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>  
> @@ -1372,7 +1370,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  				  unsigned long size)
>  {
>  	struct hmm_devmem *devmem;
> -	resource_size_t addr;
>  	void *result;
>  	int ret;
>  
> @@ -1398,32 +1395,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	if (ret)
>  		return ERR_PTR(ret);
>  
> -	size = ALIGN(size, PA_SECTION_SIZE);
> -	addr = min((unsigned long)iomem_resource.end,
> -		   (1UL << MAX_PHYSMEM_BITS) - 1);
> -	addr = addr - size + 1UL;
> -
> -	/*
> -	 * FIXME add a new helper to quickly walk resource tree and find free
> -	 * range
> -	 *
> -	 * FIXME what about ioport_resource resource ?
> -	 */
> -	for (; addr > size && addr >= iomem_resource.start; addr -= size) {
> -		ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
> -		if (ret != REGION_DISJOINT)
> -			continue;
> -
> -		devmem->resource = devm_request_mem_region(device, addr, size,
> -							   dev_name(device));
> -		if (!devmem->resource)
> -			return ERR_PTR(-ENOMEM);
> -		break;
> -	}
> -	if (!devmem->resource)
> -		return ERR_PTR(-ERANGE);
> -
> -	devmem->resource->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
> +	devmem->resource = devm_request_free_mem_region(device, &iomem_resource,
> +			size);
> +	if (IS_ERR(devmem->resource))
> +		return ERR_CAST(devmem->resource);
>  	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
>  	devmem->pfn_last = devmem->pfn_first +
>  			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> 


thanks,
-- 
John Hubbard
NVIDIA

