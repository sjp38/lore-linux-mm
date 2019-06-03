Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15827C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D235A27440
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:09:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="WCXqjpyK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D235A27440
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 641AF6B0007; Mon,  3 Jun 2019 12:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F2996B000A; Mon,  3 Jun 2019 12:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5080C6B000C; Mon,  3 Jun 2019 12:09:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id E03D46B0007
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:09:04 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id d8so3740832lfa.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lgsfrWNkeAwXitTJcoIdmm+S5jV0yGJC2wH7GAyc/RM=;
        b=MYTcgd6hr0ByFMbOYz8/L3PaF1IYWIWq85rZeZ0uivvTHIziN/ZRHwtxAAgEkj+xS4
         Lr/3H5uNKam7QLzo+o3opAJi5HDqfRHJxKX7rUIHdb6K63qMedfB5xPkrW2lAjA4mkjo
         YdHVfSNdG4N8aKIBCDWKeP1jrso3ztPpegtq85/RWHkIp5VVRDASs1Cv52uzvTXiA1Rp
         U4c8kq6bjENv3vl6SNZDOJCy4GVAcLrmQ0FtbeLfX9QrbnjIwckMDPJd5e1Mv7GCvbEk
         Nm4MtrEHk2/pfUyzsnC74rOlZGG8ewMZO/ZUX7NgOucKWUKTrb2eKw/NyF+pKpxrEFE7
         A91w==
X-Gm-Message-State: APjAAAU4ymk7OiEjCJBBowSbkl2+J1Tlz/z9pvYoaUKOL9zCvobUbitk
	KeUIVmXTXWUsTFmAGclme4I9s8Iz21y0q18Bi0h/S8Q+Nm+pMiX6XiwhEq96e+bFU2NV1mslkpp
	VYGwXXm+06auJgqwmurWshfVjQ37fEKjrsAYyjMI/KznyGf8rrmApo7BA9oqKRQcBvQ==
X-Received: by 2002:a2e:980e:: with SMTP id a14mr3229553ljj.60.1559578144404;
        Mon, 03 Jun 2019 09:09:04 -0700 (PDT)
X-Received: by 2002:a2e:980e:: with SMTP id a14mr3229511ljj.60.1559578143452;
        Mon, 03 Jun 2019 09:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559578143; cv=none;
        d=google.com; s=arc-20160816;
        b=ehS6mEmmTC3v5ozFzkufOn+cR7Dv1oTh+J9dABKPUCT+xLP//4HACq+S8P/TwzPvxv
         n4abiOShgzS9Nwx/0TS/CqGlE1YznKsOuC2X4iMbrI2/dG6RZTrKxNQDGzSKLsVHJt9u
         habbNA7w8Rndo/ZtfUOTwHvSyzr2qMTib10nvHuZ9Mynl2JIgMx+rqw4tb3JS3pdSYRu
         lsQuY7WSR05Is7y3fpFMY0thuDLGkAXtxItjnE9CP1N6F1i+fniXr/kTxLGFOuBl+2f3
         12lBcE86w5wdhxW9tIqeCJTv8nQADfMLpYgD+iZ4dH+IdJXTEQZBLUut8X+IxVnz7rnR
         XgQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lgsfrWNkeAwXitTJcoIdmm+S5jV0yGJC2wH7GAyc/RM=;
        b=HsuUnYAKb6fpveDIffM4zXOtjqGtLAC8L3hTbLlDBQbVPFc4EnFwNG0TZAyGJ5py7o
         5PmbjrbFOCr1BABDpz6F+WqcYHtsta4QW/7X//aUEdggmGe6hvhzQZ+cFSRvhoKLOujY
         1S19kKHXx2tXmFlZb6P8jfHomutShM0DDVW0SyR52mRzmeyfm5QXQcC2j9I/GQkdeOfq
         7DYioeAvvXSMC8xF5gCOb0FYPj+Xgx8OF4PF8mU2wBhkzhOU6IDVPjB/QGDIxjFaGP1F
         6/i2V/uKGart69AXO6YWpqO+Px+H58sjE/geRQUoMgM8/KqulGmnoo6MKG0sqAGoUY5/
         1+bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=WCXqjpyK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor8823539ljj.1.2019.06.03.09.09.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=WCXqjpyK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lgsfrWNkeAwXitTJcoIdmm+S5jV0yGJC2wH7GAyc/RM=;
        b=WCXqjpyK9CxskKR1Rsa2JsUVjNbLjTBCO3DKbpdiCOAgDG3/x4OwA5zT3oR9AF+TAb
         KoxRzjysV3/yPddUMg57RzzWz8pj3wl00UXp/zI8qmqY5Pxb0GSO0BkOluklf9MnQYLn
         o8mf30F5cjoqsx0tY+OcCybKIrmRF+OMKq7aY=
X-Google-Smtp-Source: APXvYqzh7kz+6EvmAxpoggzuPFfv9vFPOHVZat5sIT5ydpxGkqrggcQ9Qqsr22a0xoheMYZX+/zvZA==
X-Received: by 2002:a2e:9d85:: with SMTP id c5mr12833340ljj.183.1559578142352;
        Mon, 03 Jun 2019 09:09:02 -0700 (PDT)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id t21sm3217480lfd.85.2019.06.03.09.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 09:08:59 -0700 (PDT)
Received: by mail-lj1-f170.google.com with SMTP id a21so1555610ljh.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:08:59 -0700 (PDT)
X-Received: by 2002:a2e:4246:: with SMTP id p67mr14377820lja.44.1559578139147;
 Mon, 03 Jun 2019 09:08:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-4-hch@lst.de>
 <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com> <20190603074121.GA22920@lst.de>
In-Reply-To: <20190603074121.GA22920@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 3 Jun 2019 09:08:43 -0700
X-Gmail-Original-Message-ID: <CAHk-=wg5mww3StP8HqPN4d5eij3KmEayM743v-nDKAMgRe2J6g@mail.gmail.com>
Message-ID: <CAHk-=wg5mww3StP8HqPN4d5eij3KmEayM743v-nDKAMgRe2J6g@mail.gmail.com>
Subject: Re: [PATCH 03/16] mm: simplify gup_fast_permitted
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 12:41 AM Christoph Hellwig <hch@lst.de> wrote:
>
> I only removed a duplicate of it.

I don't see any remaining cases.

> The full (old) code in get_user_pages_fast() looks like this:
>
>         if (nr_pages <= 0)
>                 return 0;
>
>         if (unlikely(!access_ok((void __user *)start, len)))
>                 return -EFAULT;
>
>         if (gup_fast_permitted(start, nr_pages)) {

Yes, and that code was correct.

The new code has no test at all for "nr_pages == 0", afaik.

                 Linus

