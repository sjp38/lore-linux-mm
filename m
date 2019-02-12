Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4320FC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:47:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2A3A217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:47:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="UO4cG8cl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2A3A217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7706E8E01A2; Mon, 11 Feb 2019 19:47:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71FD98E019C; Mon, 11 Feb 2019 19:47:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636228E01A2; Mon, 11 Feb 2019 19:47:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 343A88E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:47:11 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id g26so154274vsp.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:47:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=u1NgC8GXGyioSAhYQLIf5mJA4+toxCV5RE8n2dMeuvY=;
        b=pzRgxSj2rU/ZIPtPIibOmB8iGnerppGvjHVQh+LWHF+lR9rg1aL1kDOW/ga2u+1i/O
         RS8MU2ZMQL4D+7Chj/9CWPww4ALDxjX5ZdxMiy6P1bkjmavsC9jSO32xYRCeFV7bHYKm
         k1c5wBWgavePTG3fl9YvXmohGYu5UmIFX+0ut5bTnK/A2VF+0acTRRz+t8NiiBb4fvYH
         5cRvK6KtUxp+6w5UgFLCN791yrEIAUzE/Hf7FNsMTc+dCrI6DBNIN5/sqnz1nUvyQS03
         zAq2noNNYx70aOZW6eFBrfKuagkk+eAOH0B0qPkWbypSFkWDfe2/zZcrY/8Jh9Z7Nzfk
         ufqw==
X-Gm-Message-State: AHQUAuYizJajxLskSdsxgzWqg4xFToV0Hk/vUx6Eh9GMUYD9+4cZsu0U
	PNoR1uVN8HRi8choHvdMwCzv9CwfmcBYWMyEoqhe+XJXP18xGRlSbVMFkVANc55QlRmmgqyUpzL
	V6lR8vyXcOrFyXFVvbLSXiIouOnJzznyPVyyYhOjQaBBtqnz2i2C4euY+yn1K4RyEjeET8fYXGg
	w7/isMJ7UqD5NVeKmg4HvTuu2erbZW/jP01fOt4ZrulerjpqO7qvZ69jVF34CgRQNYM1I/YKxO3
	qddLAm0Tizhs6C5IiEmZwx38KT1iT2JBAQNeunCxhknn1YYtcimCpzubbz1UnO8jgnEpx69XtEU
	ZNGGrNqRIIezUX2EQF5NGqDPaQzQ0O6F7o4c/CPgsMEyBKdGYDgBMhMMJC6Gtf/nPL0ejVza+Rq
	e
X-Received: by 2002:a67:8706:: with SMTP id j6mr462996vsd.10.1549932430853;
        Mon, 11 Feb 2019 16:47:10 -0800 (PST)
X-Received: by 2002:a67:8706:: with SMTP id j6mr462986vsd.10.1549932430373;
        Mon, 11 Feb 2019 16:47:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549932430; cv=none;
        d=google.com; s=arc-20160816;
        b=Jvkq+61fyIc++v+tRO96W8Q3iKFU+Y3A0QEmQHLy1oemJfUm64C/s7rZwaNuF1Szan
         Qc/43kUD5saaVvJqrc74IZ3li0nyqWkLFdTkYROcCCCsSruxqER2Sk4AhUkaKaqCEsAD
         sKWRmkqxX/PYrNzcpQJMHywdFMPbv17D4IY02C3qHPvnz/IqudPbfKKFFbRThvQK2avn
         vVI+3An7nAoTzy78jfLdOtwYmWpWvBNMBi5AAeK7QsAFOi3AWxf7SRG+cwp4DNwBGjTs
         Pza1n8jk37U8mzOJERNIesTwsVNBa9Mvj3az6O1AAElKyzBa8pAgipzvxgvfYRx6/+A+
         mrng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=u1NgC8GXGyioSAhYQLIf5mJA4+toxCV5RE8n2dMeuvY=;
        b=Eb39/9600NM8XYfbYNbah2UP0umCP6GyL1wSYElTu9spGF0h68ruNGLS7JnUxlDbtj
         m/jP3uJL9gl5xYnGPilKC2ai9zfIv5h+BszFtNTEXwBEx1KAu/+b9rVl9EF1IHkzw91W
         eVdgtUzCVJPvcxPvpHG7qr+wB4KRj9cJnYL/Z5RPpt16JaRvkwYfIzVQD0TprYT5mITp
         5Er3RJgY1sVUQcH5a5fmYW1IqeLu+2UJb4VSBsOUEo7TaeH8LvC5YTO02uqbgNFgOaCc
         7N7u7ed6hdxSrL5dRQQTUv6+IeAgf4OSKtl0opA9Npdzx5ClTwCYtKaoH13PDILc5JYL
         mLHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=UO4cG8cl;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w4sor7003528uao.21.2019.02.11.16.47.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 16:47:10 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=UO4cG8cl;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=u1NgC8GXGyioSAhYQLIf5mJA4+toxCV5RE8n2dMeuvY=;
        b=UO4cG8clCIKQDK9/zmKwPZ8QIQZgcYQggmkiSOyvw22UGFAcR3kWcR6xbmQW9KMZeU
         D2dRym+fyDyZKSpGlJFk5Mu+zKSZXOKtzAwPx4ioyemVdvOIh0l9fUKc6FTZbcUgk2Up
         9ETqSmjk+xFILiwWDtUQRCPRRgTFWy/tcMKE4=
X-Google-Smtp-Source: AHgI3IbeHG6M8uB4dt50vRR9f/a5AzLUbwO5OTC3N+OPVZZbhW7teFWYrmhl5pbTUCeTPrZxNCa5IA==
X-Received: by 2002:ab0:5a01:: with SMTP id l1mr453546uad.24.1549932429819;
        Mon, 11 Feb 2019 16:47:09 -0800 (PST)
Received: from mail-ua1-f44.google.com (mail-ua1-f44.google.com. [209.85.222.44])
        by smtp.gmail.com with ESMTPSA id b144sm2266883vka.34.2019.02.11.16.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:47:08 -0800 (PST)
Received: by mail-ua1-f44.google.com with SMTP id n32so299798uae.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:47:08 -0800 (PST)
X-Received: by 2002:ab0:470d:: with SMTP id h13mr450189uac.122.1549932428183;
 Mon, 11 Feb 2019 16:47:08 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549927666.git.igor.stoppa@huawei.com> <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
 <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com>
In-Reply-To: <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Feb 2019 16:46:56 -0800
X-Gmail-Original-Message-ID: <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
Message-ID: <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 4:37 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>
>
>
> On 12/02/2019 02:09, Kees Cook wrote:
> > On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
> > It looked like only the memset() needed architecture support. Is there
> > a reason for not being able to implement memset() in terms of an
> > inefficient put_user() loop instead? That would eliminate the need for
> > per-arch support, yes?
>
> So far, yes, however from previous discussion about power arch, I
> understood this implementation would not be so easy to adapt.
> Lacking other examples where the extra mapping could be used, I did not
> want to add code without a use case.
>
> Probably both arm and x86 32 bit could do, but I would like to first get
> to the bitter end with memory protection (the other 2 thirds).
>
> Mostly, I hated having just one arch and I also really wanted to have arm64.

Right, I meant, if you implemented the _memset() case with put_user()
in this version, you could drop the arch-specific _memset() and shrink
the patch series. Then you could also enable this across all the
architectures in one patch. (Would you even need the Kconfig patches,
i.e. won't this "Just Work" on everything with an MMU?)

-- 
Kees Cook

