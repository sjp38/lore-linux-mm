Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A6D2C31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4A442086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:28:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uikxw7Ut"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4A442086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 858D86B0008; Tue, 11 Jun 2019 17:28:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1A76B000A; Tue, 11 Jun 2019 17:28:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9016B000C; Tue, 11 Jun 2019 17:28:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 429696B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:28:11 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f19so4624717oib.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:28:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yfYsg0/cES0OHcG6fX5W9snm90ggOgAM9kXY3QBEhu4=;
        b=Gu31PHy+jYUBQwk74GLjZa99d7vCQ2BoXUFo0YdD94SYwKvuh/PUt6eybuQ7ykgXdZ
         MyoQeydmYFCc3HDH2p0pjxiIDSpo6rBf0QqmSY4t1CllTJdH4BATOL4jiD9n/mn1TzQk
         r4MUyAd/ISL/nOtf9duijiaaJNmIePCv3ydpcc2Dp2lbN1MsInWAMG1KwI0oKPBqpP2Y
         4synyt128UWP6zIQod5G9/DFsayAKRN7sSu2V5FWvfefsR8Yjn60ZE2zt9vs+7x3hZFt
         v1MsWUUsU6DlzPfffExeVEaj6uWTsNZpA+NuBE7d9vjkQH0lQRRasWUSohGLPeTAL0D8
         819g==
X-Gm-Message-State: APjAAAVYd9KkcFEn3L94li5R7IHjYvIuhpyR84sXQ9O+dar6dwh14aeE
	yZdJu8YIp3TYJseSZpv4YaQt65S+dJgo0XXAxhTIUs3lmSKqBTIpVEde8ta6plOHChTg/n2xMhn
	C8HxyxZuR6sJk2BfB1n3dmfAKsaZ1YPweMwuBL1yrvtpn0LsM7BElZZbxsDqrouxWSg==
X-Received: by 2002:aca:3256:: with SMTP id y83mr17737740oiy.110.1560288490921;
        Tue, 11 Jun 2019 14:28:10 -0700 (PDT)
X-Received: by 2002:aca:3256:: with SMTP id y83mr17737709oiy.110.1560288490386;
        Tue, 11 Jun 2019 14:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560288490; cv=none;
        d=google.com; s=arc-20160816;
        b=ht+VglvM+duH4trvyHxJoAji/RYjzI766cjsqDa/ITIPC0DeBdqxJJi1QP4cuYi8rs
         kiDbfCLu7YLTWMHe87AQu3yZ7g2HHcLentkFYlwgI7zTI9idlaCnuVmJRRgYU1/YFmlw
         Xo2tnho54YRyO0eZHKpNrb7PmYYZ0iHWGSXVULyfOb1BqEbIkRIdqQcUH47HsYR6Js+y
         xMwBqsc9xgGFuLFt1mhUEOuj5r6A/YYrUJwjnfykejzMGfGxVOaK4HuZXsdel1YglCoZ
         rpM2UMWq8CXRajXz0KT0jQfqbMARkQArykqVnWEgnB7e+7V6cXdRnG5nvCLY6liHAUrk
         t7nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yfYsg0/cES0OHcG6fX5W9snm90ggOgAM9kXY3QBEhu4=;
        b=cwwILbAkS8nQHwkVJhsDyxkeuR8ZhaiBNHjgWbZG5AWb7PvdpJvbaPgNajDQm0lhnJ
         1GUMkUVqNRvBOfCwnnUcUq58qVYlljzmF0JYXDYIAolNqN92Jp3FqsvuHAaXwWNWVrGZ
         MPYsSz6E5TrcDjkp3dqpy0j3+Jb2PaIvFE28FGrcKNqkvmXzuHTBLM2Wkxv1Uy7Ch1rp
         K9wF29l1Ge1bwprz6yKbHi/LGQ1RmRgkPwyZIfSi6gi97DS/As+Zdr8h3PkLw8VQUcX7
         w7ACEFKYI8DyxgxnyILHpdiT5prpMobllP20AaKtMCCz0OXsC+kFLfoo2mG/EXr2VorA
         XJ8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uikxw7Ut;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 70sor2838989otl.86.2019.06.11.14.28.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 14:28:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uikxw7Ut;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yfYsg0/cES0OHcG6fX5W9snm90ggOgAM9kXY3QBEhu4=;
        b=uikxw7UtyOptEVyjeY2qK4xy247KZZSlixb4FYF44cy5IOYuGfhYNz0auK7eAN3lSf
         RDykMi53c/UWnKOss3Gbf99f02SgcsLInyU9jZT7mZ9OHg9hKC6fNrTncVfEUwMvFzyT
         LcQoyh1B+GWH1wcVdCBdLQqRjW9xbNzL/XHVXJwKNd+h41OfOLBnxXrK/w2EGMY7Sdql
         Ev+iISe8afAaHYadIsKtGIEgMDX6CnpwHgbsBe+aUSzQIjTpiqosNwjLo3ub7MMP5bSh
         sv6W0b+fg0PHcDLs3IdJMwn13c7joqsHqAOaS3kYpN0/uUkfhOoBhUB3X+c5vOw3dtMp
         LbTg==
X-Google-Smtp-Source: APXvYqwZE6DuGW97Wtdkbau380s5wncliqmuWNA2I8e3nRFVHn0Gyt7oiNVh7GBK4ctz/0QIVrifVcW0qHRMDnaPYKk=
X-Received: by 2002:a9d:7b43:: with SMTP id f3mr18847440oto.337.1560288490020;
 Tue, 11 Jun 2019 14:28:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
 <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca> <20190611140907.899bebb12a3d731da24a9ad1@linux-foundation.org>
In-Reply-To: <20190611140907.899bebb12a3d731da24a9ad1@linux-foundation.org>
From: Shyam Saini <mayhs11saini@gmail.com>
Date: Wed, 12 Jun 2019 02:57:58 +0530
Message-ID: <CAOfkYf5_HTN1HO0gQY9iGchK5Anf6oVx7knzMhL1hWpv4gV20Q@mail.gmail.com>
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF macro
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andreas Dilger <adilger@dilger.ca>, Shyam Saini <shyam.saini@amarulasolutions.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	linux-kernel <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>, 
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, 
	intel-gvt-dev@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
	dri-devel <dri-devel@lists.freedesktop.org>, 
	Network Development <netdev@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, 
	devel@lists.orangefs.org, linux-mm <linux-mm@kvack.org>, linux-sctp@vger.kernel.org, 
	bpf <bpf@vger.kernel.org>, kvm@vger.kernel.org, 
	Alexey Dobriyan <adobriyan@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

>
> On Tue, 11 Jun 2019 15:00:10 -0600 Andreas Dilger <adilger@dilger.ca> wrote:
>
> > >> to FIELD_SIZEOF
> > >
> > > As Alexey has pointed out, C structs and unions don't have fields -
> > > they have members.  So this is an opportunity to switch everything to
> > > a new member_sizeof().
> > >
> > > What do people think of that and how does this impact the patch footprint?
> >
> > I did a check, and FIELD_SIZEOF() is used about 350x, while sizeof_field()
> > is about 30x, and SIZEOF_FIELD() is only about 5x.
>
> Erk.  Sorry, I should have grepped.
>
> > That said, I'm much more in favour of "sizeof_field()" or "sizeof_member()"
> > than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
> > which it is closely related, but is also closer to the original "sizeof()".
> >
> > Since this is a rather trivial change, it can be split into a number of
> > patches to get approval/landing via subsystem maintainers, and there is no
> > huge urgency to remove the original macros until the users are gone.  It
> > would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
> > they don't gain more users, and the remaining FIELD_SIZEOF() users can be
> > whittled away as the patches come through the maintainer trees.
>
> In that case I'd say let's live with FIELD_SIZEOF() and remove
> sizeof_field() and SIZEOF_FIELD().
>
> I'm a bit surprised that the FIELD_SIZEOF() definition ends up in
> stddef.h rather than in kernel.h where such things are normally
> defined.  Why is that?

Thanks for pointing out this, I was not aware if this is a convention.
Anyway, I'll keep FIELD_SIZEOF definition in kernel.h in next version.

