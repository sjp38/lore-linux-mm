Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52144C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10A3920818
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:09:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10A3920818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BC838E0003; Fri,  1 Mar 2019 16:09:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86BCA8E0001; Fri,  1 Mar 2019 16:09:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 782DF8E0003; Fri,  1 Mar 2019 16:09:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 353E28E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:09:55 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 17so18550161pgw.12
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:09:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P+tiE/zdPttgIzYWReZwXKg35jN+4/1ADTJDkXcDOZ0=;
        b=aR9QeXZPCtedhwBVjw8XvM/SEX2d1Bxte1f86iNm58QKx3NikQpwNuxxHuAlz46DI4
         3iixyiKxxJvpZVIvLqCWmCmQgT9kL3vpyK3IFU2tpW8u/5WS6L6XVvFdMOx4BbqSboWh
         hd+teUOysfYcjLjaZCY8m5hfV1oBdUbECfoa5yvtQXE0+7GQqj/sRaShOB/lutehK83A
         JYOxA/T9xIokP5+hPwdaMBtt4C8+HDHGpXvb2JbqXJdmV+UFZ8ToZvRZUOMEhUN9MkVy
         1jMZ9IclKa3Y3escw9CbeU7mXgj6LuZYQm/0ClwCaUuRtlz+5S8SLdndDadOf4N1OKEw
         cbbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWDvNf2TmgVOm7kmq7diQYbqVeNer91nJEy5EDy0fsm9kTuCByl
	kE/O1fxwNkp09oSIv9u1pyngOa0OWJ1nIghoEbzfhNjvaW4C7hiyV9qP+QsKrYlEYnPWzSePViV
	t9EAG5OZ5AIjaH0Rtus8b9tQ7T1t0fr/cXB07PuckrNUI8pceezSZTuiWAp+5GalxiQ==
X-Received: by 2002:a63:c0b:: with SMTP id b11mr3869851pgl.388.1551474594871;
        Fri, 01 Mar 2019 13:09:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqx963y/19cnUbIKnQTC6y0E5F+WUpeF/9a5yGCTks47rv6tdHL1sLv6tvEkX6Ar+7+/8p9d
X-Received: by 2002:a63:c0b:: with SMTP id b11mr3869759pgl.388.1551474593923;
        Fri, 01 Mar 2019 13:09:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551474593; cv=none;
        d=google.com; s=arc-20160816;
        b=vBsx/FRZzkhpQX5BMcNRqG45ZVoJ/+rvvAJc4LaVSPP9+QiBhLFmJkjXCAVSEc9IEx
         GSlVZpx1HZUHuYxtZAxAUHczdAxYUe/nVp1rUB9vx7qj/vq3DmWoRpbc1V1dx48W+fHl
         ZJ88KijY8IvSagdcxpYM/B6oVtdOWD840ZaedCgSjf7R9qZPmI/3beVmG2eEBfhd+gtY
         XtSiGDigPZImxeMkLD66BeTSnwL6UmQqDxK2zPoJ5Mw2den1zf6FR/jARCIk+SK1V2PH
         ThYhtGrfc8Hoo1lCMcKuWG+VXpQFVeLyjV9qtUzTUT3+MSq4i1RQtI1BjfeYnn594nac
         7fmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=P+tiE/zdPttgIzYWReZwXKg35jN+4/1ADTJDkXcDOZ0=;
        b=EUPXG4FClg9HF2VwwRES5L52/2K1NrR6piplybW6eAWeHrjI9mAjzynOPtud15EFDf
         uLqApvgA+nNDHVw8CxPsmCVrFd8IAz2jNEgDGZ2mGmd6zSXsYgW8M60P9M5Lr9qDPpPW
         ivldxGEeA/nYA+rCv4/GGREu94JfA89eMhtQ5D8sz2vUk1WHm2TYZudlj5Ywhj1IO/dE
         xQXOlkfFVqlXVIf9JkgV0Po2ibrP5w/u4Rbl0H93Q7RVdBPdPR9jxot+c2cFx75qnhpM
         7qVfoeR1vx8E0WCAeurEVzdu/OpY8c2WT6fHgaKH6Ek210rk0jxbEI2e5w5Cx2U8kpJD
         06Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r14si428726pls.306.2019.03.01.13.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:09:53 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 826EFDD20;
	Fri,  1 Mar 2019 21:09:53 +0000 (UTC)
Date: Fri, 1 Mar 2019 13:09:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hugepages: fix "orig_pud" set but not used
Message-Id: <20190301130951.67f419011da93265d36226cc@linux-foundation.org>
In-Reply-To: <20190301004903.89514-1-cai@lca.pw>
References: <20190301004903.89514-1-cai@lca.pw>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2019 19:49:03 -0500 Qian Cai <cai@lca.pw> wrote:

> The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
> hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
> its return code, so just make it void.
> 
> mm/huge_memory.c: In function 'zap_huge_pud':
> mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
> [-Wunused-but-set-variable]
>   pud_t orig_pud;
>         ^~~~~~~~
> 
> ...
>
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -167,11 +167,11 @@ static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
>  #endif
>  
>  #ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR_FULL
> -static inline pud_t pudp_huge_get_and_clear_full(struct mm_struct *mm,
> -					    unsigned long address, pud_t *pudp,
> -					    int full)
> +static inline void pudp_huge_get_and_clear_full(struct mm_struct *mm,
> +						unsigned long address,
> +						pud_t *pudp, int full)
>  {
> -	return pudp_huge_get_and_clear(mm, address, pudp);
> +	pudp_huge_get_and_clear(mm, address, pudp);
>  }

Not sure this is a good change.  Future callers might want that return
value.

> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1979,7 +1979,6 @@ spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
>  int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		 pud_t *pud, unsigned long addr)
>  {
> -	pud_t orig_pud;
>  	spinlock_t *ptl;
>  
>  	ptl = __pud_trans_huge_lock(pud, vma);
> @@ -1991,8 +1990,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	 * pgtable_trans_huge_withdraw after finishing pudp related
>  	 * operations.
>  	 */
> -	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
> -			tlb->fullmm);
> +	pudp_huge_get_and_clear_full(tlb->mm, addr, pud, tlb->fullmm);

In fact this code perhaps should be passing orig_pud into
pudp_huge_get_and_clear_full().  That could depend on what future
per-arch implementations of pudp_huge_get_and_clear_full() choose to
do.

Anyway, I'll await Matthew's feedback.

