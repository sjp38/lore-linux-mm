Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E646AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:41:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 916DF218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:41:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Zb6zL4Ba"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 916DF218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 389478E0112; Mon, 11 Feb 2019 12:41:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337408E0111; Mon, 11 Feb 2019 12:41:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8828E0112; Mon, 11 Feb 2019 12:41:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0C1B8E0111
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:41:05 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s65so12862802qke.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:41:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AlkMwnyxqiywgQrnwg1E3Cz9ULiUcCPJ5gOy2kXG/iM=;
        b=DmEkD6N6o/zHY1iOyrTxPIB/4XREKwa1i7wRVIcgUtayHhSVe1eUD6OM0Vkgail0jJ
         nvRsOOgfW9bDMZv9iLKdqc84gAS+gwmwccGz5/mKcwgBWo5JGfa/hjkjdFua1MgNWUim
         g6BKoswltgyVaBGQyeqkFCxbRO1vXcybBdYzQGeH8Rx7/IWnOJN7avy7UhTOZObMYVom
         hI3b6lCequinPBx5CfO/h1+40/GYFRSskjPR+7XCwJp3RjVjD2LHT7eS9lu5zqoJzfV8
         qdMkZlYCMBeI8qpDUvq5ToxYY85QHJnZwBuDN59GV2OJVND2ibW/mKj406S9I9/P5I5J
         QklA==
X-Gm-Message-State: AHQUAuZoYutWDue6X77DfWVOilghsXBSEv0EJVFVFxr401qQXS1eDgKK
	VlVmaxNJKwVGCcLwm5Mm5qKUXFw2c9cH8b3/IFiBECE8V4DIbnxILv05kmDp4u+nJwJCF7gYgn6
	DMEPfv5MyRomr2IxuFhwbEYtUH6AGPii5cQpeoT96A1Ukbz8ilwMeEtg7rYnEfJVxAZ1Dra6cAd
	sYbw9unjis2Io/2mxGArGpZMZezqHIQHIfhKTZrLfTdj9Em1QRDnfB44gB5vvXldKw0xxBa0umw
	+h/WnF8PZpLKhZEDvVBaysMyyywUzkNjS4Sc01bo8UN8WbSLMsuIe/eM41aGCaHUOFRLfEUxSnX
	NgQzFHK/LirHInmLD0fs6Ant1ciL+10zH2w7zHKfyB/VkNet3g5lLhQgYkVRrH+zQ5EYXugNWiV
	T
X-Received: by 2002:ac8:2f4e:: with SMTP id k14mr13236160qta.76.1549906865654;
        Mon, 11 Feb 2019 09:41:05 -0800 (PST)
X-Received: by 2002:ac8:2f4e:: with SMTP id k14mr13236120qta.76.1549906864983;
        Mon, 11 Feb 2019 09:41:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906864; cv=none;
        d=google.com; s=arc-20160816;
        b=Juq6b4prwVl+UdcgESLlxRR9K3FdN2c0TGlOvS8Vz6IZiY0XYObmP4zSJtNhHGY8a/
         Mlq8nB46e1EufbAq2KZrDBI4/RFxtpt6xSI1TCQ54D4m9jJQkyc8+8rrvHHRNyy15+sS
         SQOl0SLN8B6NCWOAG6Rv/VvA0axQlplAWl0kgzVPIucVqPULZGB7HAasIh01yo9/l7nV
         FynEGfClBwkCANNnlu9iCpZE9sFltOhl4jh1GMa7qLxDYfGVIe0v57urSDqun9NoKIFe
         KhpA1NUVsaCt/GWe+XNDDrWpbZ3LdvWDgznbn/s/8WXoiuwKgNiddzzhpm74umI9vhO9
         JFcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AlkMwnyxqiywgQrnwg1E3Cz9ULiUcCPJ5gOy2kXG/iM=;
        b=f2Q5gBIQQFvkXfJHsbeXBOIE6z7HQ9+NUMmTKvS81K7GalB1zAYX0zy2+/TQ1U4tVP
         JYRK7yB117gKjSI7Q6Nq9EOlOxXWfMAj3c9A9CZlel4UKNZOM9+JubI4PcOILf1sQCqu
         Bi2p9QyII/QOH7fb48bjux7luTac8i03YXkvAyF2Vt1lktIrJZQquyzz4iN6OXwZ8iVW
         JAyBYTzaqbVIYOCTwOwUkJT+T8YW05nBPbq+FbWygDWxdcvjQnMQvuo5K361IkxKhiEg
         skY8iP3KAVu68LCGA+ibdcTirqpkv5wCtYu5M66NHg7J769LBQmaH9mXfx8eTiM0wE7H
         LilQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Zb6zL4Ba;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c64sor3935403qkd.22.2019.02.11.09.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 09:41:04 -0800 (PST)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Zb6zL4Ba;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AlkMwnyxqiywgQrnwg1E3Cz9ULiUcCPJ5gOy2kXG/iM=;
        b=Zb6zL4BaIJPAjGFX0V1pbTe4IE2qJ+o2fCm1vYWJNlWAr0GIDK3yHZIoFhpTB2YrAe
         NApI8/4DTtlshkQI4MBtXQ+rA7CPy1rc+AuVEs/YOv1t/xOdjH5n3oDCpBIV/N0AGYOO
         hwmXK8Za8rNUdP0HErKuWaLfMeaZuu163yUyo=
X-Google-Smtp-Source: AHgI3IZR2zvMXASiBOs8UfJ47VnZ5vQ7r9KS8wsoeK0PXqbv3rG0JJwSwQlGxfVhV10SN5ISZ14ODw==
X-Received: by 2002:ae9:dd42:: with SMTP id r63mr25739025qkf.264.1549906864495;
        Mon, 11 Feb 2019 09:41:04 -0800 (PST)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id c202sm14673397qkb.19.2019.02.11.09.41.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 09:41:03 -0800 (PST)
Date: Mon, 11 Feb 2019 12:41:02 -0500
From: Joel Fernandes <joel@joelfernandes.org>
To: Sandeep Patil <sspatil@android.com>
Cc: vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org,
	avagin@openvz.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, kernel-team@android.com, dancol@google.com
Subject: Re: [PATCH v2] mm: proc: smaps_rollup: Fix pss_locked calculation
Message-ID: <20190211174102.GA16019@google.com>
References: <20190203065425.14650-1-sspatil@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190203065425.14650-1-sspatil@android.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 02, 2019 at 10:54:25PM -0800, Sandeep Patil wrote:
> The 'pss_locked' field of smaps_rollup was being calculated incorrectly.
> It accumulated the current pss everytime a locked VMA was found.  Fix
> that by adding to 'pss_locked' the same time as that of 'pss' if the vma
> being walked is locked.
> 
> Fixes: 493b0e9d945f ("mm: add /proc/pid/smaps_rollup")
> Cc: stable@vger.kernel.org # 4.14.y 4.19.y
> Signed-off-by: Sandeep Patil <sspatil@android.com>
> ---

Reviewed-by: Joel Fernandes (Google) <joel@joelfernandes.org>

thanks,

- Joel


> 
> v1->v2
> ------
> - Move pss_locked accounting into smaps_account() inline with pss
> 
>  fs/proc/task_mmu.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0ec9edab2f3..85b0ef890b28 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -423,7 +423,7 @@ struct mem_size_stats {
>  };
>  
>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> -		bool compound, bool young, bool dirty)
> +		bool compound, bool young, bool dirty, bool locked)
>  {
>  	int i, nr = compound ? 1 << compound_order(page) : 1;
>  	unsigned long size = nr * PAGE_SIZE;
> @@ -450,24 +450,31 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  		else
>  			mss->private_clean += size;
>  		mss->pss += (u64)size << PSS_SHIFT;
> +		if (locked)
> +			mss->pss_locked += (u64)size << PSS_SHIFT;
>  		return;
>  	}
>  
>  	for (i = 0; i < nr; i++, page++) {
>  		int mapcount = page_mapcount(page);
> +		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
>  
>  		if (mapcount >= 2) {
>  			if (dirty || PageDirty(page))
>  				mss->shared_dirty += PAGE_SIZE;
>  			else
>  				mss->shared_clean += PAGE_SIZE;
> -			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> +			mss->pss += pss / mapcount;
> +			if (locked)
> +				mss->pss_locked += pss / mapcount;
>  		} else {
>  			if (dirty || PageDirty(page))
>  				mss->private_dirty += PAGE_SIZE;
>  			else
>  				mss->private_clean += PAGE_SIZE;
> -			mss->pss += PAGE_SIZE << PSS_SHIFT;
> +			mss->pss += pss;
> +			if (locked)
> +				mss->pss_locked += pss;
>  		}
>  	}
>  }
> @@ -490,6 +497,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  {
>  	struct mem_size_stats *mss = walk->private;
>  	struct vm_area_struct *vma = walk->vma;
> +	bool locked = !!(vma->vm_flags & VM_LOCKED);
>  	struct page *page = NULL;
>  
>  	if (pte_present(*pte)) {
> @@ -532,7 +540,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  	if (!page)
>  		return;
>  
> -	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
> +	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte), locked);
>  }
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -541,6 +549,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>  {
>  	struct mem_size_stats *mss = walk->private;
>  	struct vm_area_struct *vma = walk->vma;
> +	bool locked = !!(vma->vm_flags & VM_LOCKED);
>  	struct page *page;
>  
>  	/* FOLL_DUMP will return -EFAULT on huge zero page */
> @@ -555,7 +564,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>  		/* pass */;
>  	else
>  		VM_BUG_ON_PAGE(1, page);
> -	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
> +	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd), locked);
>  }
>  #else
>  static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
> @@ -737,11 +746,8 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>  		}
>  	}
>  #endif
> -
>  	/* mmap_sem is held in m_start */
>  	walk_page_vma(vma, &smaps_walk);
> -	if (vma->vm_flags & VM_LOCKED)
> -		mss->pss_locked += mss->pss;
>  }
>  
>  #define SEQ_PUT_DEC(str, val) \
> -- 
> 2.20.1.611.gfbb209baf1-goog
> 

