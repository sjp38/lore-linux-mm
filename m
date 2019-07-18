Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14706C76192
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 00:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB44B2173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 00:17:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="BvTuMTyX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB44B2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 078C56B0005; Wed, 17 Jul 2019 20:17:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 029A06B0007; Wed, 17 Jul 2019 20:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5B128E0001; Wed, 17 Jul 2019 20:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 846A56B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 20:17:37 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id x19so5657128ljh.21
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=C0omOYCeBkj3DClmy7cN352yT9rYjsx3u2yS4CxQowY=;
        b=c2P7K9bt2w6EoGL7kEyLBZ4Y8p5qW6GkP/+9+KPhuCq3Ctx3NiVa7t3PDTd6nBo4ZA
         icB/ZtZzJacIpuDr2KtnjwIBnItXe9AjLNA9g0uZ9+TpEwcHpalG2yvCeBKFrja/v14d
         ZANer1JjzNNx6zHnS2AbfyF+aaYmgvjfysVs3nvGThP9MqYTybCJ0YRHA7AXICSbDt+8
         ak0A0Y/oJdMqhfjjq4GjDWH3XDJ2ea9kKy6+l9xDyN0YK9nyS5lw4lboXlUANuCNYd9N
         /4lyxoRXL3etRMxpseihvbL6zgk+mFjfZEFXo3DkP3tPAdGemNLGHax2pkJ4Daqgd70A
         neaQ==
X-Gm-Message-State: APjAAAX3nri3lV40eH+5+KCNXfsCmtc2G9wPZiemQGTdvuOMKAmEMoUu
	vwcgC5tR83n1Nn2Ls0FzPuhPLxzEYUAWv0Pcf7Q9eFxuFukWKt0317VomAccSuT++/ElCypWj1p
	43TbraX5iXFcgPBTvZXfP+v1cc5wOFI0177SeTWjGmNfTy91nZGuNYZ1WSAPIlp3whQ==
X-Received: by 2002:a2e:4e12:: with SMTP id c18mr22398578ljb.211.1563409056816;
        Wed, 17 Jul 2019 17:17:36 -0700 (PDT)
X-Received: by 2002:a2e:4e12:: with SMTP id c18mr22398543ljb.211.1563409055933;
        Wed, 17 Jul 2019 17:17:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563409055; cv=none;
        d=google.com; s=arc-20160816;
        b=V5QmMzoAD4kXcalrcl8X6qHVTAnDG1ht1nS0BhJUQbRJ8nMUS+XoKpov8kkI+Z+m6k
         0Nzqm/tSIxX1zI65CIf+hNnZf+Dyb4xEl6JdqYNKSSrtsE6AGC5wchM8ufGddX6tV2Sc
         dud7/LSaAYgJf77CNbkBGpiGOT8je9X36jgSRWVL3l6BkQqJ3QVCemaG/guiqsnVm+GJ
         SeGrhwUFL6b4BGJrg6CS2KqU6cY258+/Hdljj8tUVMECVS7jrlEqxXpS/DzgmT4SZJ9s
         5XyzTvsnGCdc3GA77j8T2IgSWi9ZxvICxPmU6JwPV9lNswpn15EYKqWpbcPmU2+AoDCY
         fDmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=C0omOYCeBkj3DClmy7cN352yT9rYjsx3u2yS4CxQowY=;
        b=ZqqMDsD4FWwefy9Oj/RGVJ9KR6XzgjoL10FynsUg0AcCyNSSvnnnfg6tb6CG+YKkBA
         s7gX5aCavkHtnvSq3Xuy5qlohiKZ5kL2+Wogg9iLJ2I6kTR6pEBhCtYphLrmZTjMj3qb
         MqnmqZzbq1ep/qYw0tZwanHfM1PLDLl+geW9gcRe21dOUZDcc2dJq29QH3GCXick1hBT
         SYGz44k+PPmKC2SDgKuO09nstaN4etVK+zrQG8AuLo8AlTDOP5vzG6q9lR0A1eSP+2ID
         BuSJN57K8ufPmKsxuaf5yZPFnSjK0oP8Rstph0eVComLZOSW2oGTZAvV2pWZmo5ILJ7y
         rwBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=BvTuMTyX;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor6724420lfp.15.2019.07.17.17.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 17:17:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=BvTuMTyX;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=C0omOYCeBkj3DClmy7cN352yT9rYjsx3u2yS4CxQowY=;
        b=BvTuMTyXw/kDbnoeAOdMjWZXqMnUi8pjAXkhvdYVsYGuIIDkcsJie3V1m70FCbZdKm
         0rMYzTZbhZpCiT6SqOeMP1CeLmtdHF3hRJVHwmZetf7zBpR2DIPEOAQl9ThV4uq0HD3S
         RKrrQmecpZjF5xWKdw5hXLilgdnrSnHHhHExw=
X-Google-Smtp-Source: APXvYqxw1NfV7Oeh7rdbBn0xuWoThHlRYIKbesVI2HKbC3Qtu/nk8tKeLPXvpSk6rYlOIEa5OGu4sg==
X-Received: by 2002:a19:f819:: with SMTP id a25mr20200783lff.183.1563409054726;
        Wed, 17 Jul 2019 17:17:34 -0700 (PDT)
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com. [209.85.167.48])
        by smtp.gmail.com with ESMTPSA id j3sm3724580lfp.34.2019.07.17.17.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 17:17:33 -0700 (PDT)
Received: by mail-lf1-f48.google.com with SMTP id u10so17785946lfm.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:17:33 -0700 (PDT)
X-Received: by 2002:ac2:4839:: with SMTP id 25mr19380093lft.79.1563409053376;
 Wed, 17 Jul 2019 17:17:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org> <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
 <20190717233031.GB30369@altlinux.org>
In-Reply-To: <20190717233031.GB30369@altlinux.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jul 2019 17:17:16 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
Message-ID: <CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, 
	Anatoly Pugachev <matorola@gmail.com>, sparclinux@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 4:30 PM Dmitry V. Levin <ldv@altlinux.org> wrote:
>
> Sure, here it is:

Hmm. I'm not seeing anything obviously wrong in the generic gup conversion.

From the oops, I assume that the problem is that get_user_pages_fast()
returned an invalid page, causing the bad access later in
get_futex_key(). But that's odd too, considering that
get_user_pages_fast() had already accessed the page (both for looking
up the head, and for then doing things like SetPageReferenced(page)).

The only half-way subtle thing is the pte_access_permitted() movement,
but it looks like it matches what gup_pte_range() did in the original
sparc64 code. And the address masking is done the same way too, as far
as I can tell.

So clearly there's something wrong there, but I'm not seeing it. Maybe
I'm incorrectly looking at that pte case, and the problem happened
earlier.

Anyway, I suspect some sparc64 person needs to delve into it.

I know this got reviewed by sparc64 people (the final commit message
only has a single Reviewed-by, but I see an Ack by Davem in my maill
that seems to have gotten lost by the time the patch made it in), but
maybe actually nobody ever _tested_ it until it hit my tree?

                   Linus

