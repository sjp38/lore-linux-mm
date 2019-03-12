Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8747C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:40:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 735C8214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:40:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uwUIrLKO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 735C8214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FAA08E0004; Mon, 11 Mar 2019 22:40:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AB998E0002; Mon, 11 Mar 2019 22:40:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDC508E0004; Mon, 11 Mar 2019 22:40:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5E948E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:40:35 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id 190so947132itv.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:40:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=L9iir7i/e3/qeKL34wiPGqGD8PwT3V1ZJYro/HToDss=;
        b=a5e18hGvLSZLFh8JSDhpTgSaAKI/TZ4/Ri7O3gWfa/xHEqCnKLSlfnYwwAGqNMRfDf
         OcLdXcjVcNoBZguWlxrYtuJ/ZBJkjRADxp7+VY3G4SPpYPnX4NJy/GYZB16729aYeZkt
         oHD5sqtA3weCxjMKoaslVh0jTkpHpoBQnHyE6j7kZOvRXnk8jKOcJvAheW2AIMJ0dvZS
         l0Ve2yMijaoJtYqSvyWFCNw7o4uK3YsmjlSU9sySeLyLMsgwmIxjZeDUjFOnEMlDgdZB
         MpxZx7kLBLs1YjXxeIsGu51QXwrVoVxqk1nfeWOie62AM0RMvfc1IlhahsgY54nVmqk/
         DkKw==
X-Gm-Message-State: APjAAAVKUoZsF1KBhE+BCWe83JbrjU7I5E45Wu9WvYkVYyTpQIzTInXv
	B8S5KXkT57q0quimC2r+FISlWutU6ShPPhWNdSGRexIXFG0f34gLhqemm8tg7BTV3CMIogintSx
	k16BDR2oduRkedktfNy4WdBTHYKENKR0yDwGseUKzoWBMux1dRMOPm/k64tDbSP77JJWf0kBePM
	lQoe537MAHK9Dg1pmICKLSghtjNHUell3T2PRIyCzo/T5Yupqpndo9KwOP+jHeeig0hmz+1Avke
	40u5yi/jxb/skwsGpdyX6IXkuswVUOgCD8j7tvPR0mriOMJ3LCHR7nzlj8xApeyf5rSoT9Gawiy
	Y3HsLupt8Ar8ZAMbvzbbVxt/LI2vxBK7524v0Ow4XA9mp6tbQ0g/KkuoqVADNGype6ChLdLOEbL
	n
X-Received: by 2002:a24:6b57:: with SMTP id v84mr623440itc.145.1552358435473;
        Mon, 11 Mar 2019 19:40:35 -0700 (PDT)
X-Received: by 2002:a24:6b57:: with SMTP id v84mr623418itc.145.1552358434657;
        Mon, 11 Mar 2019 19:40:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552358434; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUCibKhxu1GacJY5TVqBkcy0lNaL9J+QuSIS3s1259ipHM4AF44W9NBvkpHTljviFh
         7A47bKDP2bBVo39FQ6ane/lD7kiXc/hRHhygs+rNCH5wAVDpCTfBlYUP4vY2mhJ/m3ns
         24LWGZE0QL9xUBdzQQm80qH1TrdwJJNFCtL899pO8zmW6mqOSSIwMYuSVXcxonA5GE56
         HXIO2FcPPH+Mxc8PqPuXuvuA7XgPbbf27i5YDb+jhUYu9eGtVdJ7NUcdp+DSFd110DZ8
         udXROLm97IMJW4Ys1hnM/saHhi+FSK4Z4CMhuIoQUD6IKJPjLGOXwRuP+BP0XP7EUOEB
         gX6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L9iir7i/e3/qeKL34wiPGqGD8PwT3V1ZJYro/HToDss=;
        b=WHXgpY68DAX2U2Y7SE8Sx2IcB080F1pP3TL9oQdL5odFet993ajBEG6I9eKUr6A85n
         yhxJ9YSi49kc7HsgtcK0J5xMxoThrUsFdVnIBr29eoHYG580aoOLwrcDw2tX6z+qLrqj
         5YYcKf0o50pnWTITCwaxEYTRYbum45pD+ELRsHvIDKtyI6T17/QbHwK+Ez6RPgBsggbV
         38njq56mEngUEV/SuzSiiN+kPcAmKF2vJvsRKn51xIJSHA6sAF0ETSFImDBjhp0VRfvK
         SbbvKDcQZdJmRSXZ6OO7E0126MVHnzVFUjXVvGLDMZhlSfSuz/LRrnChF/KBC8dIHy9d
         6J5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uwUIrLKO;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b72sor1618126itd.19.2019.03.11.19.40.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 19:40:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uwUIrLKO;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=L9iir7i/e3/qeKL34wiPGqGD8PwT3V1ZJYro/HToDss=;
        b=uwUIrLKOOruuHHRSpKG3MCRJJRm9faUNyNOUBlKpxvxjmShRf7K4RDRu1z3LF8yR9A
         u+iioP8qjpyAB0o/YkF5BYras6qxj7Bc4v/9Obu9EysHmXF33yCLjyLbLMFEiq/mVDOK
         lqHjFZol+dsEyAvrgHXb3qlFKhFWsOlFSgB+OmKxeJEgdCXPpSU+JzGkehHYVaymROff
         b+5VlUYc2gdPeq8w8VsYc+oKpp6svbDVPHOPRsoN1OWrdxxreB0hWlvrETvLfOi+j/Cb
         oNhXXSjyFRLqd60Iop5zLSiuiY3ji8qCsQckMVlhLYqrEGlXw8b+xbkZovJ5PXFb6rom
         9BBQ==
X-Google-Smtp-Source: APXvYqx8p49hveKiwSXfrf8jM5CqYcRXU6BMuH8to0YaypBP5elF2zN0YWb50ixT+i39FW6zJnVR+w==
X-Received: by 2002:a24:7002:: with SMTP id f2mr676540itc.99.1552358434187;
        Mon, 11 Mar 2019 19:40:34 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id g24sm569103itk.14.2019.03.11.19.40.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 11 Mar 2019 19:40:33 -0700 (PDT)
Date: Mon, 11 Mar 2019 20:40:29 -0600
From: Yu Zhao <yuzhao@google.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com,
	linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190312024029.GA125957@google.com>
References: <20190312005749.30166-3-yuzhao@google.com>
 <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 07:49:02AM +0530, Anshuman Khandual wrote:
> ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
> or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
> PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
> via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
> pte_free_kernel(). These will fail once they start calling into pgtable_
> [pmd]_page_dtor() for pages which never originally went through respective
> constructor functions. Hence convert all stage-2 page table page release
> functions to call buddy directly while freeing pages.

This is apparently cleaner than what I have done.

Acked-by: Yu Zhao <yuzhao@google.com>

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
>  arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
>  virt/kvm/arm/mmu.c                      | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
> index de2089501b8b..417a3be00718 100644
> --- a/arch/arm/include/asm/stage2_pgtable.h
> +++ b/arch/arm/include/asm/stage2_pgtable.h
> @@ -32,14 +32,14 @@
>  #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
>  #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
>  #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
> -#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
> +#define stage2_pud_free(kvm, pud)		free_page((unsigned long)pud)
>  
>  #define stage2_pud_none(kvm, pud)		pud_none(pud)
>  #define stage2_pud_clear(kvm, pud)		pud_clear(pud)
>  #define stage2_pud_present(kvm, pud)		pud_present(pud)
>  #define stage2_pud_populate(kvm, pud, pmd)	pud_populate(NULL, pud, pmd)
>  #define stage2_pmd_offset(kvm, pud, address)	pmd_offset(pud, address)
> -#define stage2_pmd_free(kvm, pmd)		pmd_free(NULL, pmd)
> +#define stage2_pmd_free(kvm, pmd)		free_page((unsigned long)pmd)
>  
>  #define stage2_pud_huge(kvm, pud)		pud_huge(pud)
>  
> diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
> index 5412fa40825e..915809e4ac32 100644
> --- a/arch/arm64/include/asm/stage2_pgtable.h
> +++ b/arch/arm64/include/asm/stage2_pgtable.h
> @@ -119,7 +119,7 @@ static inline pud_t *stage2_pud_offset(struct kvm *kvm,
>  static inline void stage2_pud_free(struct kvm *kvm, pud_t *pud)
>  {
>  	if (kvm_stage2_has_pud(kvm))
> -		pud_free(NULL, pud);
> +		free_page((unsigned long)pud);
>  }
>  
>  static inline bool stage2_pud_table_empty(struct kvm *kvm, pud_t *pudp)
> @@ -192,7 +192,7 @@ static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
>  static inline void stage2_pmd_free(struct kvm *kvm, pmd_t *pmd)
>  {
>  	if (kvm_stage2_has_pmd(kvm))
> -		pmd_free(NULL, pmd);
> +		free_page((unsigned long)pmd);
>  }
>  
>  static inline bool stage2_pud_huge(struct kvm *kvm, pud_t pud)
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index e9d28a7ca673..00bd79a2f0b1 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
>  	VM_BUG_ON(pmd_thp_or_huge(*pmd));
>  	pmd_clear(pmd);
>  	kvm_tlb_flush_vmid_ipa(kvm, addr);
> -	pte_free_kernel(NULL, pte_table);
> +	__free_page(virt_to_page(pte_table));
>  	put_page(virt_to_page(pmd));
>  }
>  
> -- 
> 2.20.1
> 

