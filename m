Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5746EC46478
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 16:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3875206A3
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 16:57:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ErLvOg6E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3875206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64BF16B0003; Tue,  2 Jul 2019 12:57:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D5D58E0003; Tue,  2 Jul 2019 12:57:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49E1A8E0001; Tue,  2 Jul 2019 12:57:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 272CE6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 12:57:12 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so19503101ioj.9
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 09:57:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=d3ruOHdYru6Rpy+BKpMXi/6c+V83W2zZQqeLjuI07mA=;
        b=CnvuyoH2w1/YEkHKtg0A+1bSSKue6n8PYtJFW8z9gEtFRGgJucWZ//2jgkhqOZqAkA
         9h9dPfjOchreCIJBoyFjyxx/FDoFSuRg8Pdb7qEzYivfb2/VtwezZFpx+euAkXsm+/Ai
         aeB0I4rvhLQN/ExyFG8S7WRZKS5aH1oC2XevqZKks9EjR3/++j1PwxreJMzk+91vsOO0
         zwoncymbNc+U3PNmNPI7YtRuydzN9Ze1CqTw4xBdc4TZeGIx0JB1qq8EHtgvAxjG/7rd
         UPFIoZ9NNjzUao6XlZg6neJrbLD771ym4bQw+yBox4Pw4mAknhLpVH6B3frSPzsFyHpp
         Lrxg==
X-Gm-Message-State: APjAAAXNPtMASG4j9q7JDGq1eRBJPGmuwSlHAu+44FNSd86AAvo5bu4k
	OQm8zujYLYKVT5+ABDsC327YBw1Nazmyb4XOitl4u82RiwmA3khV5lndzv003Pph6Aah04NgefI
	yH398mOmPvJggJkyoCDN4kL/iQ3GPq4Qcx3lKfsqiWP8UYkpj3mynm5sVirK6iUmNFg==
X-Received: by 2002:a5d:9448:: with SMTP id x8mr35765758ior.102.1562086631846;
        Tue, 02 Jul 2019 09:57:11 -0700 (PDT)
X-Received: by 2002:a5d:9448:: with SMTP id x8mr35765679ior.102.1562086630962;
        Tue, 02 Jul 2019 09:57:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562086630; cv=none;
        d=google.com; s=arc-20160816;
        b=tt7mxzzGW3jmBEoEPEIMT1WuESobMDc97WX43U/CmcFExbTJ7R/QMa5AZnbqhhC13K
         qw+1j1C1EziX8biiRdCs4PAXsXhLWxLD/w4+/G2mhOth8pehdxXg6WD+s81bBDTUztUb
         gavsNbqUQ6H3uvGOgvVULzn5C7H7SuoBhX7nl4auWqiEqmeRB4qId7z2r/AsfzphZcbQ
         prz+Jvq+sSVWVTW6lLxdLH0IvRP8hzwUhUTeruCcZOfIwr3pptvEULbE0smhRNrAsTgH
         ohfqCGrhtquOgZpsgUxMB1WkRwajo0zxhfLWK+ASTXe5x7xvS5d/B+PhGHwN4hafLcts
         yexg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=d3ruOHdYru6Rpy+BKpMXi/6c+V83W2zZQqeLjuI07mA=;
        b=LL4BA62SM40lem0xdhpo6Lt9oXJHAezh9I8xdaDt/k052BxSxCR+2eEurPcI9XBEmb
         g9vcaimhfM9UAq0FjqGxvdE+E8HFB1XtzyB6qlIOyLWHCha7qaCimeV+64XyqsuI26rD
         ZoR3ML1HOi6Cv7AWqtj1FyGRYhBRK9uP3j73a8E25jCRGGonihuiQhjWCIeHh8Mj7vQP
         V73bOBD4twMY+lS5hi3aRJjRIU7JeB6DJsydT3sQ7Sibm/7uEW25aNoUpngQWSFJwORk
         qfjAVY1C8dpUQOCZirVkrYcLlg7ZLJwEQcw43hmk1UW94D14hjzU27QnfBdEY/bQ1iGW
         oyGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ErLvOg6E;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k132sor10166831iof.136.2019.07.02.09.57.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 09:57:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ErLvOg6E;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d3ruOHdYru6Rpy+BKpMXi/6c+V83W2zZQqeLjuI07mA=;
        b=ErLvOg6Ev6zdphtHAlsPI/i4E1PAFFXuaLmpX6JcmhUUgS/xmdRuySXKCpIRtG+kX1
         FsBNUdt7zVXIciKH78drKjYo4PYJhD0tQnv5rYwR3/PbGcFitIGiyFOgRNQv0cqHlGeu
         9y928edF1AI0QN3d9ySA6ju08SKBpvuUyqAVUUTBKxMF/hoGVeig2TwgtMcmDhk5bwON
         ytRV6TMwbAXFECT+G69te6UyI4Y/HZtbTAL2PPKYiox8zBVdb6HWzEWgwyGh9YaT0+o5
         RvasPdi/clcVZRh3FzLopILMMo7MJkLlQhmUJLYkDyArxNRZCsan6cYz+PMwXxGZXyRc
         2XAw==
X-Google-Smtp-Source: APXvYqy+XdTH/NEg0tFMMzUuM/+XmEQEFt0V0klg3HtEJYTy61ahf+1pdl0T/rIL9bJh57cA1/DbyP6ClHqPxMl8h3w=
X-Received: by 2002:a5d:9e48:: with SMTP id i8mr22818920ioi.51.1562086630549;
 Tue, 02 Jul 2019 09:57:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com> <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
In-Reply-To: <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Tue, 2 Jul 2019 09:56:34 -0700
Message-ID: <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Vitaly Wool <vitalywool@gmail.com>
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

On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> Hi Henry,
>
> On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com> wrote:
> >
> > Running z3fold stress testing with address sanitization
> > showed zhdr->slots was being used after it was freed.
> >
> > z3fold_free(z3fold_pool, handle)
> >   free_handle(handle)
> >     kmem_cache_free(pool->c_handle, zhdr->slots)
> >   release_z3fold_page_locked_list(kref)
> >     __release_z3fold_page(zhdr, true)
> >       zhdr_to_pool(zhdr)
> >         slots_to_pool(zhdr->slots)  *BOOM*
>
> Thanks for looking into this. I'm not entirely sure I'm all for
> splitting free_handle() but let me think about it.
>
> > Instead we split free_handle into two functions, release_handle()
> > and free_slots(). We use release_handle() in place of free_handle(),
> > and use free_slots() to call kmem_cache_free() after
> > __release_z3fold_page() is done.
>
> A little less intrusive solution would be to move backlink to pool
> from slots back to z3fold_header. Looks like it was a bad idea from
> the start.
>
> Best regards,
>    Vitaly

We still want z3fold pages to be movable though. Wouldn't moving
the backink to the pool from slots to z3fold_header prevent us from
enabling migration?

