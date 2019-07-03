Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ED2DC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:03:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E454521871
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:03:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PFhq5S64"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E454521871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DA096B0003; Wed,  3 Jul 2019 02:03:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78AA18E0003; Wed,  3 Jul 2019 02:03:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 605398E0001; Wed,  3 Jul 2019 02:03:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB0176B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 02:03:30 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id a25so106179lfl.0
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 23:03:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YR83koGSfN8f4T21Djb6M4JozxiegfBiW4pc4sENEhU=;
        b=iMo1OociTzhytha/eakTUNbMJPUsmnC1HAJZ4kDYUPqnVGTL2RfKOKId0syI2aSdrz
         Hv5O8t7tbNPbhrT2TUeQZ+41I9+uxIS+bVfVUAUYhHAlcBJNTvhJgBAmiQHPJmH7MEKL
         w/82IC+VQTf5PAPrWuXwDbfB/hLl5j5yR5Ji5wT7DDasuU5IaKmTqE9FMkgi332W5OoF
         4k9xhykH1iSx0kX76IuwNrDzyBGgJ/M/FKhLv6GPZyhf2yuKr+q35KG5fxBp9dZcvJ16
         xoeCnbCH4gceTbXPdMcytR26EQH5qKAE7mHZWhRQjbHDqyyu+MX0Rw9jgrSJRdFLqmv3
         LDOA==
X-Gm-Message-State: APjAAAXRvXEj9rET6duBOGENM0LUB7+uD5RS4jKVtD6cnMZfYg2sjxyv
	FUmFI2261LzgserhnOofpEUUPdUFoT3v7B+MXUMl6ncrDpSM2pWDpEV4PZSKYr2kGReyIALd+Vw
	b9JVnV3zKlA6KeCmmE8r2DrSDIUojuQ+M4xl+4GY80ztXevqNVWkNYdN0WSKliDDPtQ==
X-Received: by 2002:a2e:864d:: with SMTP id i13mr19232229ljj.92.1562133810442;
        Tue, 02 Jul 2019 23:03:30 -0700 (PDT)
X-Received: by 2002:a2e:864d:: with SMTP id i13mr19232185ljj.92.1562133809702;
        Tue, 02 Jul 2019 23:03:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562133809; cv=none;
        d=google.com; s=arc-20160816;
        b=bj9i0INzrb2JbZ3dRMLYShWmTHu6agzML8d9mNtxUSP7+cNYAn5z+jdGprgaNWCpv3
         Wu/2PTluMDY+kVbo5wJbcPl0xDrYyoXHdVjF9lkaMpBwo777bvfB/ZqiMZWxVQ8lCrvn
         MTAe4gWGgnH32b5ptY3VJkHq0jqfyvv1n/4RssAdMxxnIWcLZQIS+W7Va0gfAj+06CSl
         GYPbUsqpUmA2p+VxaGzG//hkH7Q8/UURbYksXwOuB4ra2xyq9AewEuIXwFFv02rX5npK
         05KC5nZwwdFXqX7JiLqyIeh6lwD2oqNV3Zo7H8lyagt542SJwCCUvlc6wdgKkXJXjurC
         3jkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YR83koGSfN8f4T21Djb6M4JozxiegfBiW4pc4sENEhU=;
        b=akeKQ2qqhemmhJC217zjo++eBymBlDrNNCHvUK5uELsxHXR1E6yHCHytQZzYkN+w7j
         1sZJpJOeIopzjw0i12KlU40/Y9G9i3rGOLjRNaefqOc73mTlAtqjI4zPtorNfFwHhoOq
         q7nS730mg6znHtXGoSKKebR/4HtD8y3xMJ/tWsPMjMSe4aB1GkMDm2osMXnycoyckBN7
         sSj1FQYBY57C1Owccx40zpYjYa7LnYIJI4s8OhzU4E1u8p559U4Fln8LbHfmQAz+kjId
         bdE8g5NX5j+5MayrkJ852msqD5/cjhHPYK/Ne6criq/Bz/BFZU7z7G1ExrdDSRmD9to4
         pN3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PFhq5S64;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor510734ljk.21.2019.07.02.23.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 23:03:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PFhq5S64;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YR83koGSfN8f4T21Djb6M4JozxiegfBiW4pc4sENEhU=;
        b=PFhq5S64bGYOvM9RVa2rbe3BMe23mBxegax68A5oboVVYkj9yac+DYKBsUV8TIxm82
         dCGgip+iJTAtzeueMH8rXwQ45n2SYFC+AJILLZRa9Dtx/5PVB/eM9wPnNOm1KyaDPc5B
         WpCwcuNCvEEkNPlwFbk1fJwDnjI9sMF3ObMHbhpCS5nEdkC8ViFucYBJDVa7o8JsLEJu
         w30fTQ8+s+plIIDzeJmOF+FLYOHg3mjz3cKsMggoNq3CRop9fr8LgDofeAmZDUYJq/Zc
         K1IcZ1OxyF73JiC5QitC8o0m7qWFaaci8gL35lYByRCuUNfS0IorVlFmxBZz6UOfcPyx
         My2Q==
X-Google-Smtp-Source: APXvYqzdUgWzjHttmuz/N8FCiFoagx183/BYjJRUjTIJAQZZEoLGL5Q9E3sSA0IdUXaoNAmAWERsIXlbn3793c0uRIc=
X-Received: by 2002:a2e:80c8:: with SMTP id r8mr5360976ljg.168.1562133809409;
 Tue, 02 Jul 2019 23:03:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com>
 <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com> <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com>
In-Reply-To: <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Wed, 3 Jul 2019 08:02:31 +0200
Message-ID: <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Xidong Wang <wangxidong_97@163.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 6:57 PM Henry Burns <henryburns@google.com> wrote:
>
> On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool <vitalywool@gmail.com> wrote:
> >
> > Hi Henry,
> >
> > On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com> wrote:
> > >
> > > Running z3fold stress testing with address sanitization
> > > showed zhdr->slots was being used after it was freed.
> > >
> > > z3fold_free(z3fold_pool, handle)
> > >   free_handle(handle)
> > >     kmem_cache_free(pool->c_handle, zhdr->slots)
> > >   release_z3fold_page_locked_list(kref)
> > >     __release_z3fold_page(zhdr, true)
> > >       zhdr_to_pool(zhdr)
> > >         slots_to_pool(zhdr->slots)  *BOOM*
> >
> > Thanks for looking into this. I'm not entirely sure I'm all for
> > splitting free_handle() but let me think about it.
> >
> > > Instead we split free_handle into two functions, release_handle()
> > > and free_slots(). We use release_handle() in place of free_handle(),
> > > and use free_slots() to call kmem_cache_free() after
> > > __release_z3fold_page() is done.
> >
> > A little less intrusive solution would be to move backlink to pool
> > from slots back to z3fold_header. Looks like it was a bad idea from
> > the start.
> >
> > Best regards,
> >    Vitaly
>
> We still want z3fold pages to be movable though. Wouldn't moving
> the backink to the pool from slots to z3fold_header prevent us from
> enabling migration?

That is a valid point but we can just add back pool pointer to
z3fold_header. The thing here is, there's another patch in the
pipeline that allows for a better (inter-page) compaction and it will
somewhat complicate things, because sometimes slots will have to be
released after z3fold page is released (because they will hold a
handle to another z3fold page). I would prefer that we just added back
pool to z3fold_header and changed zhdr_to_pool to just return
zhdr->pool, then had the compaction patch valid again, and then we
could come back to size optimization.

Best regards,
   Vitaly

