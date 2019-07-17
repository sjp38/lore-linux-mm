Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32203C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1DC520880
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:05:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="g84+xOg5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1DC520880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DB696B0005; Wed, 17 Jul 2019 18:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08C126B0006; Wed, 17 Jul 2019 18:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBD5F8E0001; Wed, 17 Jul 2019 18:05:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 891346B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 18:05:16 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id r5so5622132ljn.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:05:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YSDBsvNUqnUp/t7kjQNVbtVYe15sAK39prvQBCJ8iQY=;
        b=ceHF/cI+2UDXIT9H0KM7guTQNRoSmTsC3D7CdZj+mFpQx/zFW/mOsE8rJKWXfNVHC7
         S2jilXtFblhlGBNRcpMZ9yI3uHBO8l155FhPZeOR8O8FR7k//LH101i4IxdHr7jixZse
         fsQ0dSt2RMUx0v5m8bIBm+rgoLIczFi5K8m8yRsL3Neu7ggt8VN0J4HhtBnAslAowkxx
         mrVykn5Mx4tH3hIIJMdPjMlJj81qKMqJsYP6lct8cNEeXKD5fVbOFlSQXLH0dZakORwW
         2aI2NFkS7F/g10A4YWq2CAxaY2gEIJSlHNfFdrxL3nl4lTRvLKxr+jyGcB+m1DHoB/u8
         g1mA==
X-Gm-Message-State: APjAAAXbIIUt5DgiaglL5DUAX2djJcig7BlSQZoBIxj+h+3kXyrCRSis
	ifNTLKisoi3BAICQ9X0CmzQsCoVaTRlWFy7iORl7dS1Pfh3q5ZOqVpbV9rk3FzNdFVBK1Ro21fF
	Ce4cdeFPDVCiieF19hcXjORVOFlNLhZv/NZNj8cnUQ7J430Eskjpf51Si2p8sbrbWSQ==
X-Received: by 2002:ac2:495e:: with SMTP id o30mr19051155lfi.140.1563401115871;
        Wed, 17 Jul 2019 15:05:15 -0700 (PDT)
X-Received: by 2002:ac2:495e:: with SMTP id o30mr19051129lfi.140.1563401115149;
        Wed, 17 Jul 2019 15:05:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563401115; cv=none;
        d=google.com; s=arc-20160816;
        b=nCfbV040M8dLiwc9xeaOOkTVGdhwleNSt//8JvC0qbPX5RdekBrkOLSjGT5iBbD3a8
         zsoYHU+c77Z1xXXcLQaJf7ajdsPgGL5wVUAxf0jwDgnS81WLpnSD+WtJFJvci6BmbFU2
         h5bmBG3XUrVQy53EJsgw0Wj9fhWjxk+OIo8KsgNiMs+/4vt91SDlsVmsL6Tdf9Kumqhz
         EDL8W3bYRb7kK7HxoeB+f4/GJZtFV7c19OAhMGEA1p0jSu2Nc1yjWyig8WbHCHxos5nE
         mcIDqVoSCghjOXgAufvaD5yjz3wA7BRExMGJTvwHHDfsXqXgeceIlIrqXjvtdysLH5iK
         7WNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YSDBsvNUqnUp/t7kjQNVbtVYe15sAK39prvQBCJ8iQY=;
        b=N9vgu3g9taihvAVkuV0TqVVhRfkZeJigN9e4KR4DpoSZwnGaFR/klhg3urlV8OfScu
         cZhB7AW7C9X2d/fltxwWNFmf/XIpym/clZ5cyAf/YMDLfJG0o0+zDOznFjr9SzrF9x1l
         BK2sxTQBLr4o63Fvyit5AKt0ZYclguXAvyaVAQp9sFsF0URnLWD8u1GPq3mgK0pIpcCW
         0ZWlaUS8MRKe0w1qYde0aBuRPGWi1XrM5Dl3SNRdL4D/0e/DPjWL2Cb6biq4aVsw6Sh6
         KYq8pCRP1CUiHu7y80d7bHvsmTpJejEuX6SqHKGyJFrIo7sAK2PWX2qTX7ElaMetqcuf
         I96Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g84+xOg5;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor6896064lfo.57.2019.07.17.15.05.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 15:05:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g84+xOg5;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YSDBsvNUqnUp/t7kjQNVbtVYe15sAK39prvQBCJ8iQY=;
        b=g84+xOg5RI1fWUeKUBJwojGU94tRjD8iZnr7jFeKgSFJWGDE5P+hiJZ/fByUC7X2Ud
         Qp+qvIYxZtjYMQm2/OAIJKIyXJb/8NX7XJR0SU91SEDjU6fmhg1H4carPg11uTh9RG8E
         J486BoqJAuMyOcptmKjQRPSZoDYh89CS+IIos=
X-Google-Smtp-Source: APXvYqyjJSuV+12rAr3h6vjva9b6AsjqQ0DE9o7aE8kp1CPcIj4Tlw5YZ0xPSz161IkxzES2R4clQA==
X-Received: by 2002:a19:f819:: with SMTP id a25mr19936331lff.183.1563401113750;
        Wed, 17 Jul 2019 15:05:13 -0700 (PDT)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id j3sm3681217lfp.34.2019.07.17.15.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 15:05:13 -0700 (PDT)
Received: by mail-lj1-f170.google.com with SMTP id r9so25206091ljg.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:05:12 -0700 (PDT)
X-Received: by 2002:a2e:9192:: with SMTP id f18mr21972538ljg.52.1563401112629;
 Wed, 17 Jul 2019 15:05:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org>
In-Reply-To: <20190717215956.GA30369@altlinux.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jul 2019 15:04:56 -0700
X-Gmail-Original-Message-ID: <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
Message-ID: <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
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

On Wed, Jul 17, 2019 at 2:59 PM Dmitry V. Levin <ldv@altlinux.org> wrote:
>
> So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> (thanks to Anatoly for bisecting) and introduced a regression:
> futex.test from the strace test suite now causes an Oops on sparc64
> in futex syscall.

Can you post the oops here in the same thread too? Maybe it's already
posted somewhere else, but I can't seem to find anything likely on
lkml at least..

On x86-64, it obviously just causes the (expected) EFAULT error from
the futex call.

Somebody with access to sparc64 probably needs to debug this, but
having the exact oops wouldn't hurt...

             Linus

