Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B9E1C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D04020643
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:04:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EHg4bkzT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D04020643
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDF256B0007; Wed, 17 Apr 2019 07:04:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8EF16B0008; Wed, 17 Apr 2019 07:04:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B86906B000A; Wed, 17 Apr 2019 07:04:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 980376B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:04:01 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id y19so10419247vky.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:04:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=XeDE+yliHZIB6baClgy0wFy6iqkcSebRIAatOB4mZZs=;
        b=togjGrda7xydtd2IW5RY86MvxqjCBenz6RBpBbmpEWjlH50vBNz8ig1faPpvxuZlaz
         SCsJvHYcP1BJ0Ut+qVA7DEmyO80zC/+Y9KMI0jKTGXhK/GPyjgHLlOsKnDyxdARHOQJM
         P0n/tAvIVkyA8HPS8J1TCNhTsVVLee1r09xtirlXNWhihyFdJ2/QIiv0acAInpzLRAZy
         JP/ILv/UtEZLeUEzxwpMRbBlXAEyzoFgWMwUC568BZY4LnXKGAKPbtJjppvuhPJXPEDA
         zmt/km59vEIVi7KpyUlQBQp3OXPz2iAYbzX2dgbwflPDobFQgBcMaztmS9pOfykowOzJ
         lU6w==
X-Gm-Message-State: APjAAAX4LstV4I/q5tLDKEXhDpaX/FUj+3DfKfnIzxAu83z88wcSgTq9
	wZmQrgyW8+1IdCSfW9Tixr8DfO7miktkCWGmU3oAcnybXBkJge1td94KHFPfJboJr1FN/ntNtTY
	P8u+ccf+KNsvmySfwH5mSZm7UNVBX98mNoulJdHBW9OvhjIRE9+F4Ie5+L4xxHggDUg==
X-Received: by 2002:a1f:900d:: with SMTP id s13mr46896057vkd.41.1555499041237;
        Wed, 17 Apr 2019 04:04:01 -0700 (PDT)
X-Received: by 2002:a1f:900d:: with SMTP id s13mr46896022vkd.41.1555499040550;
        Wed, 17 Apr 2019 04:04:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555499040; cv=none;
        d=google.com; s=arc-20160816;
        b=c/8FOqSyNKwO5jDCdqHfu0GqO3OQrZmOVdW7ogpHtwvdWe8q7oL35DQ+ucBjOz8jPx
         oVrMHXYSNrOLa82vzzRq9fMEXiptEe53zVobqsUqrnnTNgBO1hXb71lT4dvZUlvX5keP
         AbSKtZ5Nbf/X4LfypOQ5CBl49izs8GoyuVJRyx50e6cB4S28RXMtRQTeqfDYNHIPr+XX
         mO8Ns/s0guFCo+CBGYEGnoebJbAp+GaZa/qgyWEe136IxWsTgtF9FiTBwzbjkw5sdtQk
         KrmYbHKLLq5YYESHq7dKY1orzRRiiPlPYOT1QBge74ipxJwqxND0LDLtOoZxBjuRNiLh
         86MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XeDE+yliHZIB6baClgy0wFy6iqkcSebRIAatOB4mZZs=;
        b=1DTBB+ehiezkJ9NAch7z4eeT6U0h1cR1ou0aNIB91i3XAHTVCJ2Fra0tdj/mvoH6Do
         f7DRSablufoahpjT2s5picUjjOFFTi/IKXZo6K4Acqd1OQAg3Z6Uwvn+qfuKd4za8mIb
         KqIVSbfSh/zqScZSSmtV52FbauH1/XDBrpqo8PVAAS9fnkqqcKVB0uotS7OfqWwXB8Z2
         67FvzvOi2K11rZNke2KEmD5Vf2qPpi0gXAG62scbGITyZ9EoVU1kNLVlSBRtrOdVGcuv
         cEz8YocRg6imBF5pfkvhPxUEJxK8brwMSZIigy64lnI83OzxMs8Wq9DK0YmETwbbMsS/
         kC4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EHg4bkzT;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor16080726uao.72.2019.04.17.04.04.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 04:04:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EHg4bkzT;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=XeDE+yliHZIB6baClgy0wFy6iqkcSebRIAatOB4mZZs=;
        b=EHg4bkzT9P1/JvcPmxKZjCTm2qTW27sUH6jAZrudgbPjINDmUdAu0PJJBES0yqqfbM
         4bmaJy/iA7sVnk7/hM31UEvD0tlNU1sME5r8/KCDj17pumJmRdaMjj8FTutuxwha04UV
         Hb+I+Ty/L8y/Rj5LpF5Lx46sV/3HYHDSq33xcjulilS+R7hzk17b0DKooLFNyUvBO5Ri
         8nGRYmNdRdao+0mBTWnx7M8FwWsao5CXd5HpuWqEYApjHnK8IqOocHZjf/Qv62L9rLYe
         NPcDQ64TzAYN0jvMeQ5ny18GH1eeo+vMRR0GO9rlz+/AhE23AOkFjEQek7sR1P3hZzQ7
         nMlQ==
X-Google-Smtp-Source: APXvYqy0E3lOpUwtTrpEaKPRLMulbyV0QY+JC8lDgLgnW7DMw5btc81OU9z96BdM4Fsp2n1Yb0l562FqvRLMrcRc0Ww=
X-Received: by 2002:ab0:2b98:: with SMTP id q24mr9040711uar.122.1555499039971;
 Wed, 17 Apr 2019 04:03:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com>
 <CAG_fn=U6aWfBXdkcWs0_1pqggAC16Yg8Q6rxLiVeiO83q1hOCw@mail.gmail.com> <0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@email.amazonses.com>
In-Reply-To: <0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@email.amazonses.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 17 Apr 2019 13:03:47 +0200
Message-ID: <CAG_fn=XW=-=SiAjToBNGDBdr1iZFA-9Ri_a4tF40448yPTbU4w@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 6:30 PM Christopher Lameter <cl@linux.com> wrote:
>
> On Tue, 16 Apr 2019, Alexander Potapenko wrote:
>
> > > Hmmm... But we already have debugging options that poison objects and
> > > pages?
> > Laura Abbott mentioned in one of the previous threads
> > (https://marc.info/?l=3Dkernel-hardening&m=3D155474181528491&w=3D2) tha=
t:
> >
> > """
> > I've looked at doing something similar in the past (failing to find
> > the thread this morning...) and while this will work, it has pretty
> > serious performance issues. It's not actually the poisoning which
> > is expensive but that turning on debugging removes the cpu slab
> > which has significant performance penalties.
>
> Ok you could rework that logic to be able to keep the per cpu slabs?
I'll look into that. There's a lot going on with checking those
poisoned bytes, although we don't need that for hardening.

What do you think about the proposed approach to page initialization?
We could separate that part from slab poisoning.

> Also if you do the zeroing then you need to do it in the hotpath. And thi=
s
> patch introduces new instructions to that hotpath for checking and
> executing the zeroing.
Right now the patch doesn't slow down the default case when
CONFIG_INIT_HEAP_ALL=3Dn, as GFP_INIT_ALWAYS_ON is 0.
In the case heap initialization is enabled we could probably omit the
gfp_flags check, as it'll be always zero in the case there's a
constructor or RCU flag is set.
So we'll have two branches instead of one in the case CONFIG_INIT_HEAP_ALL=
=3Dy.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

