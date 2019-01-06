Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33785C43387
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 15:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1F5120665
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 15:58:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SkA4frcs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1F5120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75C168E0145; Sun,  6 Jan 2019 10:58:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70C268E0001; Sun,  6 Jan 2019 10:58:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FB448E0145; Sun,  6 Jan 2019 10:58:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 345FE8E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 10:58:00 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id t133so46175548iof.20
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 07:58:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JkBL0OqRR8zXMtEYO0UTsWFjYJr1Dpt+h22KR22cHwY=;
        b=k3lpeyUKwleTFGeVa9Rz7GXUBxgSVjqpDE77t8frk+LvImnSCrrRnRwbSKX5vcqkAg
         Pw8cE1xO0nuUIBx1pCjZMiH6xVE8TADKQ99btOaAaQ3HpgsXnnQyFbuvVF9sNQd7aWcJ
         n2ObdlMra1OUgCY7Z+T9+pf9i2KsWU/3Qww1P7ePguEdgz0B8/niFrGozZuhUshpeyox
         SettYMCuuz1Gpnr8bEaeOiCcO7hV3mEJ2bw1W0R7xVs1WeguhGqFr+szy1u0JvF+DLpd
         Uul11SHAeRtZ8XBqRomJiwNzYji7OSnfyYq0CU7P4vSucAl6hYyqaDwZaEVZePjUxbwY
         TpaA==
X-Gm-Message-State: AJcUukdoqyCFc8Mk2BpvG2BOVGg+9k8kGM56TJUeZII1BAScWJ+bEb9R
	+VLl+i/0h7Poic1A6AeNRZhRJuGds4rzAovlmgnfqi7xi2uvnKzf/T52C06L6AVTuexPjzvKxLX
	llKNt62vItyIZ7qdTaQAws9RK84myWP9RuM+LIkbpZvVeZ5ErcZKrpRl/84e5rLHwlpLiIdLep4
	/HyQmHZ9wUzUyn5/vXW8J1sR90Y1rQBRna99n/TZ3jDcR3VeBzG5aUpbrIQ2gg7/ZyAdxecLCSu
	Z1ZZdiLXhph9ScSeAdGG8CjCsKUTU/B3OGv8aHyWMRuHY/GBwrS2dkRGBD6N9opBL0IrL8ZvICX
	r5dQQ/hEqaUgdD6hg9JyxSbJ+eIwiFsyVfvJX5yF0C+m75177Voe9lZXfj7tJwXG9nZ+qTNy2Ah
	o
X-Received: by 2002:a5e:da49:: with SMTP id o9mr5258565iop.246.1546790279953;
        Sun, 06 Jan 2019 07:57:59 -0800 (PST)
X-Received: by 2002:a5e:da49:: with SMTP id o9mr5258541iop.246.1546790279268;
        Sun, 06 Jan 2019 07:57:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546790279; cv=none;
        d=google.com; s=arc-20160816;
        b=vReSIotjQUHg9/0lfIvhBRVdy7RA2HXiQmaQzdEE3T6EwkDzxbQ5utaXAXMsJn4Rvh
         Mp43uYAPSiHBbhiCEHDdwzU1W+9Yco9jxZ2gvjqC2XCYs8uijMWtTA+EVIYuH9ad674+
         oDFqt/6LJRfOAAVu3pkiWotT4mVkYsXiv1r8aQbw6oCPflD3XS4OwUr7kljHf6eO3K+I
         Ep7dV+WWK3ZhIS7Trqvs4pDKpBmS89fKVgA0W78mHKN+p70gpft2ryvfIhUp1DXd0WHX
         NvbgYCXGiq49Hu33hCBZeRGzx/1bBStHxfbv6p82HzfK5iklSVpgnIvcJRxUqc5t9oHP
         eWKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JkBL0OqRR8zXMtEYO0UTsWFjYJr1Dpt+h22KR22cHwY=;
        b=ymzZOPg0909PW2qbLAfUyo3FRcYd73I+hLcRgcUcVBWGg+TR+go5zDSIE+WDMVbbdZ
         HLoQ+AqtjUu5DDQOKvPiwMsP4m78/x7f9FSiRYYNIkcn/AfqsBHiN0wQLraI3pnckjMD
         Gma/rGEKaXBG7ffONRUkmj3xiHPVcydWjCK6YjemUQw6wR71T2KyKqZBclt6Km63lK7D
         o+InyEzQ4p7d6aoEeBRuXiH5eCGQdwsH4h0Bmhdehw551WCOM74vEmYXILjsmy/4DOyy
         p2U0y/Wy3S13UivrSt+45nlZaO/TTbR9Ap+G1g98H0FmXOZVJAjz2rnu7ui1PyHuEW1i
         9qzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SkA4frcs;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor23583883jad.11.2019.01.06.07.57.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 07:57:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SkA4frcs;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JkBL0OqRR8zXMtEYO0UTsWFjYJr1Dpt+h22KR22cHwY=;
        b=SkA4frcs8LrrxbzvNtbPBlfp4LF+8jBIkn0H/R6PZohfoy3xUUmV6f3TAAPlwFyMBS
         amAvwhbgMTSCyxG9ujzwOWvyqKyY83YLP9G4n2wHKSyEwmnPEJSbtnyg9nw1T4LJA3hZ
         BExY8G42lL11zTkIjAxrcAaacGpPNCBLOFHPkzuprKvy5x4RDBYOn5gcWTq67jLLbZBA
         NHTq7S3vygCuFT7sgjnx4nNYwLhzEO1EG7QkGDHT2jOpzCL2Aw9Boj/MQl+sgEhl/ArW
         ebRed4euYGmMVHH+Ee5CxW3Gq/YKILgHEJR0mIJJa71+QPcqFPeA3Yd1NyR5UFhFChLo
         3IkA==
X-Google-Smtp-Source: ALg8bN7XX94A5Z/E7xTpscROm4xxzJRiZP0fvOXCJQBzb/kmJ4+oCUKyxukcYWb0SnAj1/KQttwsmKcnp3xcCLvucDU=
X-Received: by 2002:a02:97a2:: with SMTP id s31mr25791875jaj.82.1546790278806;
 Sun, 06 Jan 2019 07:57:58 -0800 (PST)
MIME-Version: 1.0
References: <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
In-Reply-To: <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 16:57:47 +0100
Message-ID:
 <CACT4Y+avxq-9MshcDAtKMpGbQPBGvAmK801TuTgiK12onM9H9Q@mail.gmail.com>
Subject: Re: [FIX] slab: Alien caches must not be initialized if the
 allocation of the alien cache failed
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, Linux-MM <linux-mm@kvack.org>, stable@kernel.org, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106155747.GE-GtRo9jwNoCAVkAoxoFQYv1agvIv-JIic0Y39HJQs@z>

On Fri, Jan 4, 2019 at 6:42 PM Christopher Lameter <cl@linux.com> wrote:
>
> From: Christoph Lameter <cl@linux.com>
>
> Callers of __alloc_alien() check for NULL.
> We must do the same check in __alloc_alien() after the allocation of
> the alien cache to avoid potential NULL pointer dereferences
> should the  allocation fail.
>
> Fixes: 49dfc304ba241b315068023962004542c5118103 ("slab: use the lock on alien_cache, instead of the lock on array_cache")
> Fixes: c8522a3a5832b843570a3315674f5a3575958a5 ("Slab: introduce alloc_alien")
> Signed-off-by: Christoph Lameter <cl@linux.com>

Please also add the Reported-by tag to commit for tracking purposes:

Reported-by: syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com


> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c
> +++ linux/mm/slab.c
> @@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
>         struct alien_cache *alc = NULL;
>
>         alc = kmalloc_node(memsize, gfp, node);
> -       init_arraycache(&alc->ac, entries, batch);
> -       spin_lock_init(&alc->lock);
> +       if (alc) {
> +               init_arraycache(&alc->ac, entries, batch);
> +               spin_lock_init(&alc->lock);
> +       }
>         return alc;
>  }
>

