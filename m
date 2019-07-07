Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C8F4C48BE1
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 16:01:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2E4F20838
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 16:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nCwfu1OY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2E4F20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 819E98E0005; Sun,  7 Jul 2019 12:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CA6B8E0001; Sun,  7 Jul 2019 12:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DFE38E0005; Sun,  7 Jul 2019 12:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF728E0001
	for <linux-mm@kvack.org>; Sun,  7 Jul 2019 12:01:43 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s83so16144924iod.13
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 09:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kpL69YTVdvgy2bgbCOoUAnMPb0H84df6WGk7mkMI8Qw=;
        b=Q5300KotHCa527KtrhN/0FkgRHF2KzKXQ6aoUZltSWbMSI9UA+p5ID8An/apIR/YKa
         43CbThREBtxnzSkYl73+8qjfTnR2bnE5QAd1vvWSjVbHoarkRseDL+N/WRNz0PGnyXqu
         dHztRzT6KctFFT02ywRPoOde1FryVjh8OSi8MN1mfThPdgBSLndBVFzE+PHGpu8pWGjy
         hpF08DUBXw4ySWTMNncs+J8I+wLrSTBT0c38VqcNY7LD60Hk1p1V0JXJfx1HswpoFBRO
         s3A59r9XVuNR9fflxrr9BxKRjq7XsKf1M7z3HL+IBdpj1+JR/EBncP4q+iRQREayb0Rt
         +5mw==
X-Gm-Message-State: APjAAAVveF0yg0a6xau1d5PFm9C33sejJlTXhrro77USiMPYdRjj/88B
	fJkG9Bl0gHAUsQ25TJJynU16pfJdnNP23gkkzAlaXpRjbwxTA+OPbZxHhkLHt6KocH+v+5MyaYE
	335j80T74P/qGDxshsqOnYBTMB40lbnB4DzjS+zDIiCtr9u8KkrekLXqYT7tfFJe2tw==
X-Received: by 2002:a6b:b206:: with SMTP id b6mr15418252iof.286.1562515303112;
        Sun, 07 Jul 2019 09:01:43 -0700 (PDT)
X-Received: by 2002:a6b:b206:: with SMTP id b6mr15418212iof.286.1562515302541;
        Sun, 07 Jul 2019 09:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562515302; cv=none;
        d=google.com; s=arc-20160816;
        b=0ncBU73rfGzzu/VYIddmomtmtdgTmwjy7E9UTY4bP33zQXiOQaKGiqJqaWN6xzCyBo
         9TraSRxhkc2SunllKMZ/bk6iEElGfKpAlrTRfwOv/bR5uLy9/lFASc6TJK8nTzyzfOY4
         oKHgBf1oXkmXkPTrMpjUqvjlIlgrb2MhpnfZrA3u2z/ie7hV3oz5J/sG5BQVHrf8LCDp
         p4EeZTKikIKfxz554mMoYeQacnHPAgwyunMy6cOcAVWUiuKpcSigEiTGt6tmDIVl8Em2
         Vp2dunnIpVMkRjgF8N4oPH4oYzGAX8+r0ZDYFQciImq6h3vmfnZEQM17k0IQHfCBZbOv
         W8xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kpL69YTVdvgy2bgbCOoUAnMPb0H84df6WGk7mkMI8Qw=;
        b=aAEVOWanwSxXUY5swhPs8lfyUCle2T0QO/DwbGW5T/TWDUi2vFX+KQ/meXWAGmW7YI
         Q6dg4fhCX3R5p9BDUNYGmMOT5YBJvpVtiLvBEbR7uIlAe57m4W8JTi5bB8scTrQeOsFw
         0UjhipcYgcyHDSBa9kCQCcz4a7kdRX4ZsOVt88zfiMH5nJTQn/WShvPwD9/wYdVzoma7
         2UKU3WDvPRocUbZrj8x96oEJW11RbxbX1gtsiBv67zcj1ECAtQ8UOKHNz0rnpt5Tq3Bs
         NRNP2DZY04wh4CZHJhvgkH2j7ODI543B7wW1AOXZ5J2iUcMSpgEX3PV4eX2IxbRLY02P
         5Sbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nCwfu1OY;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor10497265ioj.63.2019.07.07.09.01.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jul 2019 09:01:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nCwfu1OY;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kpL69YTVdvgy2bgbCOoUAnMPb0H84df6WGk7mkMI8Qw=;
        b=nCwfu1OYXtJXAuz5Lw4SgN1PmgDQUVSLIFq+2jh1XLmUp3piIngxYlk0KmfkFI1FdU
         ROOz1oYuYpPTsIRC19fMn50wHKiL/1gzimzolIXiaiQbaMHI7/jEq3bXle+03+OUSiDc
         vb8XG3QFPTFXCgHoRzC3t4VI3dM5wY+VV08O9+8PRER8D6corxQOdB2qjaeH6UCQ+QcP
         FBAc9oCbnVJZQHcsSuN32Wru3Ez2SyPRyHYLFtpT1SvyMWXfGXVY0oh+ribE8rBorJx1
         csI7+IjL0WhDtEaVwk2kiNc+fitKtaiRXFvzVURUwwFo3mTjAhcUNR/9yv01OnRYj5l9
         zVaA==
X-Google-Smtp-Source: APXvYqz+gbqDipYXXJauAyDBwpal9ZoBFjQ62TKLSgnXN1ufM0R8ek36cAH6qd6K24dcXtDGiOBZvXmI/J8cVswrx5g=
X-Received: by 2002:a5d:940b:: with SMTP id v11mr1384909ion.69.1562515302185;
 Sun, 07 Jul 2019 09:01:42 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-5-git-send-email-s.mesoraca16@gmail.com> <CAG48ez35oJhey5WNzMQR14ko6RPJUJp+nCuAHVUJqX7EPPPokA@mail.gmail.com>
In-Reply-To: <CAG48ez35oJhey5WNzMQR14ko6RPJUJp+nCuAHVUJqX7EPPPokA@mail.gmail.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sun, 7 Jul 2019 18:01:31 +0200
Message-ID: <CAJHCu1+35GhGJY8jDMPEU8meYhJTVgvzY5sJgVCuLrxCoGgHEg@mail.gmail.com>
Subject: Re: [PATCH v5 04/12] S.A.R.A.: generic DFA for string matching
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, 
	John Johansen <john.johansen@canonical.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jann Horn <jannh@google.com> wrote:
>
> On Sat, Jul 6, 2019 at 12:55 PM Salvatore Mesoraca
> <s.mesoraca16@gmail.com> wrote:
> > Creation of a generic Discrete Finite Automata implementation
> > for string matching. The transition tables have to be produced
> > in user-space.
> > This allows us to possibly support advanced string matching
> > patterns like regular expressions, but they need to be supported
> > by user-space tools.
>
> AppArmor already has a DFA implementation that takes a DFA machine
> from userspace and runs it against file paths; see e.g.
> aa_dfa_match(). Did you look into whether you could move their DFA to
> some place like lib/ and reuse it instead of adding yet another
> generic rule interface to the kernel?

Yes, using AppArmor DFA cloud be a possibility.
Though, I didn't know how AppArmor's maintainers feel about this.
I thought that was easier to just implement my own.
Anyway I understand that re-using that code would be the optimal solution.
I'm adding in CC AppArmor's maintainers, let's see what they think about this.

> > +++ b/security/sara/dfa.c
> > @@ -0,0 +1,335 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +
> > +/*
> > + * S.A.R.A. Linux Security Module
> > + *
> > + * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License version 2, as
> > + * published by the Free Software Foundation.
>
> Throughout the series, you are adding files that both add an SPDX
> identifier and have a description of the license in the comment block
> at the top. The SPDX identifier already identifies the license.

I added the license description because I thought it was required anyway.
IANAL, if you tell me that SPDX it's enough I'll remove the description.

Thank you for your comments.

