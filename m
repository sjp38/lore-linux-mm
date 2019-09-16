Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7D27C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:04:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E98220830
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:04:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L2Ma8ZVb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E98220830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1667F6B0269; Mon, 16 Sep 2019 11:04:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1172B6B026A; Mon, 16 Sep 2019 11:04:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D0B6B026B; Mon, 16 Sep 2019 11:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0231.hostedemail.com [216.40.44.231])
	by kanga.kvack.org (Postfix) with ESMTP id D7C196B0269
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:04:42 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 725DB181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:04:42 +0000 (UTC)
X-FDA: 75941105604.20.wax33_290a2e9617b1b
X-HE-Tag: wax33_290a2e9617b1b
X-Filterd-Recvd-Size: 5443
Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:04:41 +0000 (UTC)
Received: by mail-oi1-f179.google.com with SMTP id a127so44086oii.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:04:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=12uVa/vbHPUsxTmhn6LwynIHFIlD+WNeKDV9FVDcoCg=;
        b=L2Ma8ZVbuNQumBIZfwwzqwuIJBH/sB/nvGaAtEa16aHu8hlvyh258IjngMEZc1mZD4
         0T5E0L51ExctaPzEWG1RV+1gtBklRsIlu65BcmreQ/7j/nBpZKcVLsRfkZN9i6UPaznC
         xhvIsEbMVJ02056XbscM4QHEj6trIxVdTTOu72e6ElzdTayi5Qol+SXgaWodwayVio+F
         siU4VmORQxf7x6BS/AOEuPvvcPWG3r8zrVKgQWuEZ00VNq2+Bsvq0XeHC/YIyuUoGQkT
         GT7w7PEkGuIPEkZPm496ATcqqc7cQAXYIe+wPc9CsLGdiPKZPu80gbeWpFbw3E/LKp+0
         ld6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=12uVa/vbHPUsxTmhn6LwynIHFIlD+WNeKDV9FVDcoCg=;
        b=qTn5EQR8fjTCTDvR4Ch30WE333jt4HVYm5YoP3iJ0MiaxJ8gYczGjBj5VNKAy+SHv2
         YLOYU0bak0idTgBWHpfM5UezaMRrSn6IqNOvcVny7+BxnIiLqkLZ5u8uvY2rhsXAnmBS
         hjXFwjc3sfnrhVz/h2o3OvwkZZzfDLBYA06lhjP2UJ3hehPKtcGnPWmWLJ1EnGdW26PD
         J+6+hy1TSifX+FN9o8XH0nOD02kwUpxwQwVNpQ46fekOWYB34d5q/40OzsKLsqribvTy
         7wKbVdA8TDqFw6CxDfVi8/dK5KpsgJKsbamgRBrGMmR5Ab+/FYaHZRrTu0QMqRwf+amJ
         /0Jg==
X-Gm-Message-State: APjAAAVQNCt8nP8f6vgz6/Ur7mGviHPipMICF2riFYMrFHLyfnHdMnB+
	znzYjEyQnkkTs82RFSN6sAaqxqUgF/tefOd76m0=
X-Google-Smtp-Source: APXvYqxzDJAmTOkYMBzaGEFLdHsuC8Q9Yf1wDWuj9OY97A7AAyO5m/qLr8u76F/E9fl8BiSr4oS6zzWdGUiu4aXVzG8=
X-Received: by 2002:aca:4f8f:: with SMTP id d137mr3394oib.33.1568646281210;
 Mon, 16 Sep 2019 08:04:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-7-lpf.vector@gmail.com>
 <alpine.DEB.2.21.1909151434140.211705@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909151434140.211705@chino.kir.corp.google.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Mon, 16 Sep 2019 23:04:29 +0800
Message-ID: <CAD7_sbEKRc0ipTh2SU93C9wJ8hOdqpwFFhacFkWg0Yn71ZYQfA@mail.gmail.com>
Subject: Re: [RESEND v4 6/7] mm, slab_common: Initialize the same size of kmalloc_caches[]
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Christopher Lameter <cl@linux.com>, penberg@kernel.org, iamjoonsoo.kim@lge.com, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 5:38 AM David Rientjes <rientjes@google.com> wrote:

Thanks for your review comments!

>
> On Mon, 16 Sep 2019, Pengfei Li wrote:
>
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index 2aed30deb071..e7903bd28b1f 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -1165,12 +1165,9 @@ void __init setup_kmalloc_cache_index_table(void)
> >               size_index[size_index_elem(i)] = 0;
> >  }
> >
> > -static void __init
> > +static __always_inline void __init
> >  new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
> >  {
> > -     if (type == KMALLOC_RECLAIM)
> > -             flags |= SLAB_RECLAIM_ACCOUNT;
> > -
> >       kmalloc_caches[type][idx] = create_kmalloc_cache(
> >                                       kmalloc_info[idx].name[type],
> >                                       kmalloc_info[idx].size, flags, 0,
> > @@ -1185,30 +1182,22 @@ new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
> >  void __init create_kmalloc_caches(slab_flags_t flags)
> >  {
> >       int i;
> > -     enum kmalloc_cache_type type;
> >
> > -     for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
> > -             for (i = 0; i < KMALLOC_CACHE_NUM; i++) {
> > -                     if (!kmalloc_caches[type][i])
> > -                             new_kmalloc_cache(i, type, flags);
> > -             }
> > -     }
> > +     for (i = 0; i < KMALLOC_CACHE_NUM; i++) {
> > +             if (!kmalloc_caches[KMALLOC_NORMAL][i])
> > +                     new_kmalloc_cache(i, KMALLOC_NORMAL, flags);
> >
> > -     /* Kmalloc array is now usable */
> > -     slab_state = UP;
> > +             new_kmalloc_cache(i, KMALLOC_RECLAIM,
> > +                                     flags | SLAB_RECLAIM_ACCOUNT);
>
> This seems less robust, no?  Previously we verified that the cache doesn't
> exist before creating a new cache over top of it (for NORMAL and RECLAIM).
> Now we presume that the RECLAIM cache never exists.
>

Agree, this is really less robust.

I have checked the code and found that there is no place to initialize
kmalloc-rcl-xxx before create_kmalloc_caches(). So I assume that
kmalloc-rcl-xxx is NULL.

> Can we just move a check to new_kmalloc_cache() to see if
> kmalloc_caches[type][idx] already exists and, if so, just return?  This
> should be more robust and simplify create_kmalloc_caches() slightly more.

For better robustness, I will do it as you suggested in v5.

