Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 191FCC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:56:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1AE3217D4
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:56:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="U8i1ubLZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1AE3217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53A426B0003; Wed, 26 Jun 2019 18:56:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C35F8E0003; Wed, 26 Jun 2019 18:56:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365548E0002; Wed, 26 Jun 2019 18:56:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F105E6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 18:56:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so192873pff.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:56:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lYpkZPTX74T2ffIw2Dsub+OKE0abvghKdi68DMjPsYA=;
        b=f7rO8ItCmgS+dsbFMOCZYWNkmK/mu9TMxYrWn+vwPY0ovx0Mfr+SkJ8+xtsL9lFVjN
         fks4bEbqRIuT1fyzfLLBTe+40QYNp7fUYtOU5Aadku38uNM8fKYvzDKG0BCB9VhZoF1p
         8YFmUBN5VFj031pYgxeOo0qjIH7CAU6xvXSA6fZxLr1setelF0yfl+bEn2rQTK2rFLSH
         VKnrjjhDpVf1mGlvWHifh/QPEHTWGzqwaWVz17hgLs5r5fWP5StGGaGw+eGM0NdD82+S
         nhj5DzQehpMywEmQEwFchUJiLK1uwNZDW2efAkgGkCLYCxAx/IoGtzyOI3f8YYiaQFav
         ffgw==
X-Gm-Message-State: APjAAAVJnw7Zz2sKwbSq9fhHpPKu0wlYgeKvdSLsx8jQ6gVw3hqGyXD1
	DA8ONZMuha7d9FErLAM9S20wZuNNAUbqsULCxUTlBQhx3JbAm4T/qAvrlcJQLcwLXZikHHAp6lK
	yHyOoR8c68AMmVJ3ATNNZskj1lhKQN3YRVxf8e2am6bToC/f+PzcbEr+ZVw9evm/gvw==
X-Received: by 2002:a17:902:124:: with SMTP id 33mr619467plb.145.1561589813508;
        Wed, 26 Jun 2019 15:56:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDrrazo+ioV9YOrqbE9W2uhK1qiYJIr2qA3DdlrOdRth1rK9f0Q1OlpaE5oPJXvSS7p8hC
X-Received: by 2002:a17:902:124:: with SMTP id 33mr619413plb.145.1561589812695;
        Wed, 26 Jun 2019 15:56:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561589812; cv=none;
        d=google.com; s=arc-20160816;
        b=EvLCfGL9io5BEEisF+AXbOWEktykxvfIrLUBRIai0/NDIvEW7LxflM5wewC9W4PzvT
         VRoIgxqRjqlB8oxJMDZwvbaXUAQA1jl/QJAahbJuQmpBXruVmUtI8GmZizwu5Oi3o+g2
         Wo+4Wsk951lMvw1LHw0/y8sdwoHbqECLsNIunR+i69Nc7J6hFYvpmizQbd5582F2VHmS
         B8dfRSPxrwsbARzhC9G+ID+DWE/OGs+kGVwPQUjrKvCXGqFQ2q7li1laP4XhGi20n0Xn
         SZ1NxEA4qMV6SJlZgQRkRgq4rAz5Vrt7f/aTz5dSzMBSCJ5NfmqJEY1Vr/+/bWCi5bxA
         dkYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lYpkZPTX74T2ffIw2Dsub+OKE0abvghKdi68DMjPsYA=;
        b=vxgFiYNrJSrP1JaAV9/3fY9AGT0elyqQDDl2X18tdBI+RhygeFrHFUoGdg6emnS8Zr
         lLiw2n9hnUfOG8Nx+HESZ7Q0ipB2dbrcLHk2l0JlZ7PDMx3zMLXz2mZ01CzC4jsRstlD
         rurYGltkhUoRTntkC39En8NJ7/UlQoqdQzg7mUPP0o+cXuRHFYlB9Zsmesg8y0I15ueU
         ks7Vt3fRXXBsB1IC+ZUKIVYcHV3Vp6aA+/LJjJf0pfOo8i0ABuRwempTeuI4iKbe5Ijr
         NKKMlfxO0l/2wH6HFXhU9wYjyINlcGRYmPpKqJqiaDxfG7Qswkvb3G8vqf5spuLWUBan
         jpOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U8i1ubLZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d7si443522plj.74.2019.06.26.15.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 15:56:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U8i1ubLZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5E37B20665;
	Wed, 26 Jun 2019 22:56:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561589812;
	bh=yo71BW543URwix7cTvmxvou/Zqigt30jEMLC6h5wM3M=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=U8i1ubLZG8J4ORUFtJT9VaSwjplP7PFznXjZlFjbkT8vcj1CPbzEhVYA4UciiVHS4
	 8eLWZCq2wrGjdOfMWluyOt5aWiUrLV4FKs5hVM50KqPKa3oWocNyuTRvNa4RWgyEgV
	 FxQPxsvU/bUCjxH2iFU2OCmzE3l+6hzGOhndb46c=
Date: Wed, 26 Jun 2019 15:56:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Marco Elver <elver@google.com>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko
 <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, Christoph
 Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mark Rutland
 <mark.rutland@arm.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org,
 Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v3 4/5] mm/slab: Refactor common ksize KASAN logic into
 slab_common.c
Message-Id: <20190626155650.c525aa7fad387e32be290b50@linux-foundation.org>
In-Reply-To: <20190626142014.141844-5-elver@google.com>
References: <20190626142014.141844-1-elver@google.com>
	<20190626142014.141844-5-elver@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 16:20:13 +0200 Marco Elver <elver@google.com> wrote:

> This refactors common code of ksize() between the various allocators
> into slab_common.c: __ksize() is the allocator-specific implementation
> without instrumentation, whereas ksize() includes the required KASAN
> logic.
> 
> ...
>
>  /**
> - * ksize - get the actual amount of memory allocated for a given object
> - * @objp: Pointer to the object
> + * __ksize -- Uninstrumented ksize.
>   *
> - * kmalloc may internally round up allocations and return more memory
> - * than requested. ksize() can be used to determine the actual amount of
> - * memory allocated. The caller may use this additional memory, even though
> - * a smaller amount of memory was initially specified with the kmalloc call.
> - * The caller must guarantee that objp points to a valid object previously
> - * allocated with either kmalloc() or kmem_cache_alloc(). The object
> - * must not be freed during the duration of the call.
> - *
> - * Return: size of the actual memory used by @objp in bytes
> + * Unlike ksize(), __ksize() is uninstrumented, and does not provide the same
> + * safety checks as ksize() with KASAN instrumentation enabled.
>   */
> -size_t ksize(const void *objp)
> +size_t __ksize(const void *objp)
>  {
> -	size_t size;
> -
>  	BUG_ON(!objp);
>  	if (unlikely(objp == ZERO_SIZE_PTR))
>  		return 0;
>  
> -	size = virt_to_cache(objp)->object_size;
> -	/* We assume that ksize callers could use the whole allocated area,
> -	 * so we need to unpoison this area.
> -	 */
> -	kasan_unpoison_shadow(objp, size);
> -
> -	return size;
> +	return virt_to_cache(objp)->object_size;
>  }

This conflicts with Kees's "mm/slab: sanity-check page type when
looking up cache". 
https://ozlabs.org/~akpm/mmots/broken-out/mm-slab-sanity-check-page-type-when-looking-up-cache.patch

Here's what I ended up with:

/**
 * __ksize -- Uninstrumented ksize.
 *
 * Unlike ksize(), __ksize() is uninstrumented, and does not provide the same
 * safety checks as ksize() with KASAN instrumentation enabled.
 */
size_t __ksize(const void *objp)
{
	size_t size;
	struct kmem_cache *c;

	BUG_ON(!objp);
	if (unlikely(objp == ZERO_SIZE_PTR))
		return 0;

	c = virt_to_cache(objp);
	size = c ? c->object_size : 0;

	return size;
}
EXPORT_SYMBOL(__ksize);

> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1597,6 +1597,32 @@ void kzfree(const void *p)
>  }
>  EXPORT_SYMBOL(kzfree);
>  
> +/**
> + * ksize - get the actual amount of memory allocated for a given object
> + * @objp: Pointer to the object
> + *
> + * kmalloc may internally round up allocations and return more memory
> + * than requested. ksize() can be used to determine the actual amount of
> + * memory allocated. The caller may use this additional memory, even though
> + * a smaller amount of memory was initially specified with the kmalloc call.
> + * The caller must guarantee that objp points to a valid object previously
> + * allocated with either kmalloc() or kmem_cache_alloc(). The object
> + * must not be freed during the duration of the call.
> + *
> + * Return: size of the actual memory used by @objp in bytes
> + */
> +size_t ksize(const void *objp)
> +{
> +	size_t size = __ksize(objp);
> +	/*
> +	 * We assume that ksize callers could use whole allocated area,
> +	 * so we need to unpoison this area.
> +	 */
> +	kasan_unpoison_shadow(objp, size);
> +	return size;
> +}
> +EXPORT_SYMBOL(ksize);

That looks OK still.

