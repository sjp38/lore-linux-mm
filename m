Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 343FBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:16:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E50C82184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:16:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E50C82184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83B106B0003; Wed, 20 Mar 2019 04:16:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C55E6B0006; Wed, 20 Mar 2019 04:16:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68BF76B0007; Wed, 20 Mar 2019 04:16:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 170B96B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:16:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so582197edr.12
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:16:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gMOuqOcjvcH0Tt3eGgc58YsblYaSfwnwK1xt4I6S798=;
        b=VCibttsP1+ZWIStIVVXrusDxQv7HU7HvLLAddgByf53xBWBr4UMJfW+1TfMhL5CcBT
         ne/QJcHYEqwBzm9RGK+P/oPn51TyC1wdG4Y/XmFelPveCCjSGOfPV2NzY6MVf3HTsDOK
         dy7Ado688ADOaCm1WjsOGG50PgvL8usFdhmUactr48HZU2hCy13JbUJ8N16NMqBd0X9n
         mzfuGeLJyEqxib1CTLstSWZzo4YNojoPeVgTvHd+CeC9XJCemFFptVCX7JwyMhg5anu7
         XrayvRtz1yw8v382mxvLyzEAVNcTNrvLbMSvZGmkghVnn7c6qGIsIcGZHXq0pTYinJHQ
         xtTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW33l2sOabCfVXtS3cqtOpr7XJP8bxuRRFsp78i/CGiKXQgt5eG
	08E/saPpaUHQaHqvxAMMXTvvIHcUAISzwOje+SQ7Ajx7rjbL94/Zz+JDgvd80LlQtPEqJO6PuE/
	PM969yC8J/naBk+BeFr7+u28whYKFvLdho/wgdVb7dlvlvW8z0aOOgoRaaTb8Qhrl7w==
X-Received: by 2002:a17:906:54d:: with SMTP id k13mr16198496eja.207.1553069808633;
        Wed, 20 Mar 2019 01:16:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx74f1GZTXggBPnZoUQMbXKAXuw3ogrvi9ykw7mjoEAoXmDSs0oDa9XePnHN/QYhiLc8r4R
X-Received: by 2002:a17:906:54d:: with SMTP id k13mr16198464eja.207.1553069807696;
        Wed, 20 Mar 2019 01:16:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553069807; cv=none;
        d=google.com; s=arc-20160816;
        b=S5ewMiJ/gz4+rUHR7hZqPaV0HR/AHTZ5fkwwcOD4yjecaFz96kTAFOpfz+x8n97hCk
         4cI/lvV2/+agOuOrEBPloJ0NNJ78UAKP3KY0m/plCa7heWXC9V9pbVqSSY5jo7evjgsU
         dQCHA45zm4zplo0Y1BLzaVW/8HTafPj0zXzmA2CkkTeyblKiji/JTlsNnTgKCjOXU9xX
         6RC9jmLOV1rG+4I1ErrxW6lahBzQHPD1KH0E1I712cyycEzVYez+TrZXgPewAzy0tGxM
         Z6u/Yelapvrr+lIFVk9f/zGzIOtriT2dwcM4wPIzqB8HR5XqXLpi5vSP5RLy4s1KjB15
         BJOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gMOuqOcjvcH0Tt3eGgc58YsblYaSfwnwK1xt4I6S798=;
        b=z0WngHfCYriGZUnv4I6gA71A7z/RidP6+PjlLnfQ0QpmR6KZGtjdS39jy3OQRFcKbo
         LcYrcD/cJ/dIuwAHCSi0YiBIsuIQR97ubnnuvkVMku2V9JtB5hjmXDc5hK8do62VzeCv
         3nFFMl4xc7UD3abdUKm79UKsSEPIT3DDt+1pFnb1fyeI8vRcZC+tNx0ZgEcfLtwIi54k
         +5Vbm9ZDVv/hY9RM5Uo0cCnO5u0/wfx2kFypr0ABfd570+LH5mIpuMERr1PFcyd9e5BU
         lIWKTDyES5P1HCdwF9Vk77Eba8W2lL7gh4HkUvdvIwHDUNjuoqw9pO742YTrlGz7+k0i
         5hSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id d31si552553ede.313.2019.03.20.01.16.47
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 01:16:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 83BD2461B; Wed, 20 Mar 2019 09:16:46 +0100 (CET)
Date: Wed, 20 Mar 2019 09:16:46 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
Message-ID: <20190320081643.3c4m5tec5vx653sn@d104.suse.de>
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 02:35:56AM +0800, Yang Shi wrote:
> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
> Reported-by: Cyril Hrubis <chrubis@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Hi Yang, thanks for the patch.

Some observations below.

>  	}
>  	page = pmd_page(*pmd);
> @@ -473,8 +480,15 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  	ret = 1;
>  	flags = qp->flags;
>  	/* go to thp migration */
> -	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +		if (!vma_migratable(walk->vma)) {
> +			ret = -EIO;
> +			goto unlock;
> +		}
> +
>  		migrate_page_add(page, qp->pagelist, flags);
> +	} else
> +		ret = -EIO;

	if (!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) ||
       	        !vma_migratable(walk->vma)) {
               	ret = -EIO;
                goto unlock;
        }

	migrate_page_add(page, qp->pagelist, flags); 
unlock:
        spin_unlock(ptl);
out:
        return ret;

seems more clean to me?


>  unlock:
>  	spin_unlock(ptl);
>  out:
> @@ -499,8 +513,10 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
>  		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
> -		if (ret)
> +		if (ret > 0)
>  			return 0;
> +		else if (ret < 0)
> +			return ret;

I would go with the following, but that's a matter of taste I guess.

if (ret < 0)
	return ret;
else
	return 0;

>  	}
>  
>  	if (pmd_trans_unstable(pmd))
> @@ -521,11 +537,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  			continue;
>  		if (!queue_pages_required(page, qp))
>  			continue;
> -		migrate_page_add(page, qp->pagelist, flags);
> +		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +			if (!vma_migratable(vma))
> +				break;
> +			migrate_page_add(page, qp->pagelist, flags);
> +		} else
> +			break;

I might be missing something, but AFAICS neither vma nor flags is going to change
while we are in queue_pages_pte_range(), so, could not we move the check just
above the loop?
In that way, 1) we only perform the check once and 2) if we enter the loop
we know that we are going to do some work, so, something like:

index af171ccb56a2..7c0e44389826 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -487,6 +487,9 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
        if (pmd_trans_unstable(pmd))
                return 0;
 
+       if (!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) || !vma_migratable(vma))
+               return -EIO;
+
        pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
        for (; addr != end; pte++, addr += PAGE_SIZE) {
                if (!pte_present(*pte))


>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
> -	return 0;
> +	return addr != end ? -EIO : 0;

If we can do the above, we can leave the return value as it was.

-- 
Oscar Salvador
SUSE L3

