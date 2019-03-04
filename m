Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64D1FC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 12:02:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2473F20815
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 12:02:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZPLxhhUG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2473F20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A84528E0005; Mon,  4 Mar 2019 07:02:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A329D8E0001; Mon,  4 Mar 2019 07:02:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94B068E0005; Mon,  4 Mar 2019 07:02:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB268E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 07:02:38 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id y86so1055400lje.1
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 04:02:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=guNt41lbGYnWxFVBh6b7n+727OGehx1dipKcWFoG7GU=;
        b=oCEu/zv3Z8DBJ2ovLPdLKDiBsuteokMfISkRIoTbSE1AWrNT2TsesAPQ28GVgCSdpJ
         sXfB/2VTsjCuMxZ3oHbuLlkNMzXzqmCcZhQH+2xN5q30obEu2Hsyf1+vdMiVI5XrInhr
         GVedTcKcSSl/hpfxVKvIPofDLriaEZ+G8Q/forLuC6oDhihvc+JrtxcZaBNiqaMb5axX
         4mdPWg65+tHXEgEYcUAaZVIKeN5qp2rpIPjf6kG9+d5ZE3fj90CfOHSeuaQrc56o1uhn
         wefX25nm5pjPNi7QUyfKz2JABR315G7x9BBL88tjnkEDAQUx1obK8Q+4AMPFiPYNv/Yu
         KVsw==
X-Gm-Message-State: APjAAAW2+VU4LFZliBjeyh8zlIwNtAxhiOs8Gos8PHTjRDyd8fygIVgZ
	0pWrTtxJgqgT78yrRg8eezB60L9bOwe5n66+WBRrAFotxl86HwmYlTuaXJt3YRRW6IdPGA/6ncL
	U3WFA/z62wWiH80GALaLzIjX4m+d+XMmpdcjQDQpEfCqIb+u68HkM4qCH7GtgJWe36105rQJ2aM
	GlOJVRV6sK+RsKFfU6YwiQHpP0ws81CVfzD9rWHp+skC0UBaHm+qiyyuOnA3rtFeP0b9p2R5unV
	l7YaziUvKAD3O4FdHcc9SY5jCln7vjbcuvpjlxTOgo09fTHg/5EtvFOVyXacCycAjQ+AU6gJqhv
	oS65xEhzEg5+xGSguwOiTrGvcdblAnTWUu93FraQ7g2J5PFao/ZIrl9ibmq6mC6oFhUIdATfw8c
	5
X-Received: by 2002:a2e:9c97:: with SMTP id x23mr10353128lji.13.1551700957244;
        Mon, 04 Mar 2019 04:02:37 -0800 (PST)
X-Received: by 2002:a2e:9c97:: with SMTP id x23mr10353081lji.13.1551700956111;
        Mon, 04 Mar 2019 04:02:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551700956; cv=none;
        d=google.com; s=arc-20160816;
        b=GSQBs+YXBCUw6bo4zf8bmiVlfHds8KJHOSulaWC02Gccw6jg6t1QulcCdVQIt5ohtl
         P35P/uGS+/1KJChl5BoWYULgiGjySlK8m6PHS7Ae7b5DjlXrrHaoged+rBrwmWMMI1AG
         ZhXMG8anSW7M9iJAnvYINk/w7vxKXiuUOXy+haWgi2uOYuWRZS7X9kAYDuqikUHTOYHM
         r2yp/QqGiiikzI0ANKRgpUsnT1rhUnCynSm4YcoLJ91kQpQGbREtZwkqc7R797DAUzV5
         l51aOSn1fNlAsrZpK+SfjGoV/1AVFpcPW7H+H6pZHBvcX4jpQ2VOzPUSY8M4fOWeQ+63
         1rWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=guNt41lbGYnWxFVBh6b7n+727OGehx1dipKcWFoG7GU=;
        b=ZYJM0goA7j1UesKQH0InDTwRrPmlqZl4gRLpgftGYL2Popg/twDnyLvkJJKvd146ce
         NAhNMUO5Iiy6jCN71EYr5/WoCXSYojZjVlZ2Tta5798ixEZ3zjQhP1yZaqRtGsxSJ9Ps
         S3gdr7PR2kT6WN4umEgFa/oXIdO/0qS4KQnFG459TYnQsXSHW0MrorOyRdCdx3e6ImoK
         6gb4Dzf7jS/WyZNw62xQn5v3Ss7Qif6FL8qfNJdsVutjtzJVKbRL10uq4npn7JK5/H+d
         P/OJQmavKyNWfmXILvJaXAt4lmGpnW30fFhmjIYk/+67f3+BqfhgXaOOdLYsj5Y2nbxv
         u+sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZPLxhhUG;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m194sor1110050lfa.25.2019.03.04.04.02.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 04:02:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZPLxhhUG;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=guNt41lbGYnWxFVBh6b7n+727OGehx1dipKcWFoG7GU=;
        b=ZPLxhhUGFE6sMjm3CSX4MszZlekzYseSBuXShoSJEbve7Xpt+HQY7w3aeVVyLg4Q0E
         rz7SXNHehlssV433+XEAIW+tp2lSezTqc63anXsa40gxQxPKcIq0TAONzL0VJ9OskPbj
         cW9TXVBRh4OsrAbIh/rubW5G2pUGiuBhpaaI8DCsn1cPa94gFdXHKiOs2tk9j2Vs5UD/
         uCaUrU4iFVtcw6CzLfZz++4nKr1QmZM8aNt4MW5ACPNOBmdSQBZx4rqcM0LExoa5rwmF
         AvM1oSs13MP69AGzes7Y+Hro3O0a6R+ve/0ZfnI3ZQ/LLFc0W1qDaDpeMudvr0MEYGWP
         H66A==
X-Google-Smtp-Source: APXvYqwTv7X0l7CJX5Q+fwXLGzCLGVXxXCL2whRIaEOeg66goYUFjExi/LN7QkAWUW581E0nKcG2hg5XtTmEUY4VBZk=
X-Received: by 2002:a19:4bd1:: with SMTP id y200mr1046951lfa.64.1551700955508;
 Mon, 04 Mar 2019 04:02:35 -0800 (PST)
MIME-Version: 1.0
References: <20190301221956.97493-1-cai@lca.pw>
In-Reply-To: <20190301221956.97493-1-cai@lca.pw>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 4 Mar 2019 17:32:23 +0530
Message-ID: <CAFqt6zZr8ZCM6_7QDzDEf=5gH=+EkaumXk86X35dGTdn_SLvvA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/hugepages: fix "orig_pud" set but not used
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 2, 2019 at 3:50 AM Qian Cai <cai@lca.pw> wrote:
>
> The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
> hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
> its return code. In order to not diverge from
> pmdp_huge_get_and_clear_full(), just change zap_huge_pud() to not assign
> the return value from pudp_huge_get_and_clear_full().
>
> mm/huge_memory.c: In function 'zap_huge_pud':
> mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
> [-Wunused-but-set-variable]
>   pud_t orig_pud;
>         ^~~~~~~~
>

4th argument passed to pudp_huge_get_and_clear_full() is not used.
Is it fine to remove *int full * in  pudp_huge_get_and_clear_full() if
there is no plan to use it in future ?

This is applicable to below functions as well -
pmdp_huge_get_and_clear_full()
ptep_get_and_clear_full()
pte_clear_not_present_full()




> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>
> v2: keep returning a code from pudp_huge_get_and_clear_full() for possible
>     future uses.
>
>  mm/huge_memory.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index faf357eaf0ce..9f57a1173e6a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1979,7 +1979,6 @@ spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
>  int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
>                  pud_t *pud, unsigned long addr)
>  {
> -       pud_t orig_pud;
>         spinlock_t *ptl;
>
>         ptl = __pud_trans_huge_lock(pud, vma);
> @@ -1991,8 +1990,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
>          * pgtable_trans_huge_withdraw after finishing pudp related
>          * operations.
>          */
> -       orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
> -                       tlb->fullmm);
> +       pudp_huge_get_and_clear_full(tlb->mm, addr, pud, tlb->fullmm);
>         tlb_remove_pud_tlb_entry(tlb, pud, addr);
>         if (vma_is_dax(vma)) {
>                 spin_unlock(ptl);
> --
> 2.17.2 (Apple Git-113)
>

