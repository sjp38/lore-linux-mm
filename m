Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F7FC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4603322C7C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:32:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gQ74RKc+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4603322C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2D76B0003; Thu, 25 Jul 2019 12:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA3EE8E0005; Thu, 25 Jul 2019 12:32:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B91CF8E0002; Thu, 25 Jul 2019 12:32:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 865746B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:32:47 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q14so31261837pff.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:32:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=OKgzFeHdg3Ku4H+GZnC9pLfW3Z4D1feqUYwGaJi6wmI=;
        b=hN6U0GYFLhZ7WZbyc/Hg0j4qs/CE8yPE3Wl5p1ViVMFVjt2mm/nQdFGksqdtZmHidj
         21fd6wiPjJxI2IsakM+PdxecBOA552H4bawZ/CoKluzoI8LLhPHMrmZRIw+bW1Q2qKm3
         cgw/vhTFLa6yDylIY0J1e/eghyQLkjg0AxdFtzAQ776K/FwYCje7QfWLEG8AVU5RkkvO
         2Fxc3VFJ8t9AFon349MDsmJwSxe7pS1BvUf/7GVrVq5WhTKbKCLmtTaT6kAeISknSsO1
         f7kJ6xhOVS800ffbwXdZW4LVMvFgLcQ6P1AzMPnI91vsO9ElH/JfiM7R/x0/IYKdOlMc
         R5XA==
X-Gm-Message-State: APjAAAWQGuyWP7oXZw5lV4ro+N42QRgj1TsM8OPMxJXBXWqBj+fYBAGX
	+U7m1D5ZC2IiOT5+xCBt3iIdKrO9YGEieInloVmz778s/kBu/s7GWMgVmAUIeQThcrLnWDSuf0m
	y9f8W7y8Lw2CvVm8qSPHCKNsHQ0x2y2h1CrPMjPqFUJql9HMCLOFHpSCrkEU6Ibuykw==
X-Received: by 2002:a63:2cc7:: with SMTP id s190mr74791190pgs.236.1564072367024;
        Thu, 25 Jul 2019 09:32:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpBovbprfB78JaO2Sc0fD8E2hjSD0NhszS8fYRXcVohbeJXNgvbv25UtC9iu+G48vcJyzV
X-Received: by 2002:a63:2cc7:: with SMTP id s190mr74791115pgs.236.1564072366149;
        Thu, 25 Jul 2019 09:32:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564072366; cv=none;
        d=google.com; s=arc-20160816;
        b=OOBNIlX50Y4zW+cOCYOasMuCpH3SE4OduPy/1rZn573oB7MiohNMmqdGv0ySM0wxw7
         CBgsgJGmxqgMNoWPGlYitQh5bauokJaJbkqz56nnovNpoOpHUrKXR93unk6NmtUIomuu
         5n70DjBXWvYVgMYbVNSmmNjMx2v8tzdMNvU/upd5729ZWH0XqqBnvtxkSXXLAxBh8Jky
         meKlD4lGWyZNPZ7kAnTUFi3+1fK35yR8O8GuK9/RU6FxayqJ/L0RD7vw4ddlqzozwCjY
         kF1v4oLT0cM80kJ6M0yC8a20UNehh6HDEgugpgchbloBlRVpgi06ypBRxciOwsMXf1j1
         rXiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=OKgzFeHdg3Ku4H+GZnC9pLfW3Z4D1feqUYwGaJi6wmI=;
        b=Yq+xNJ9aXDlmx1Tdjn8B3VXS27mXOyAv/lQb3HnC7l2OBgIQNw+H60FDhkc77HGU8T
         ap1ohxfxnPJDs3V06JEUWj1MEy32evYX7aMXQVv/3P79CuwM79pVevcT56uHz0iDDTG0
         1C14V6oThSaKsBffoCrwJv3Oiw5HPFT8PPgWoqFPuVn3hS9TbJ77VlGeFTuU53ObdiL1
         ZSJJIqq4Lf/gP20beZYlJeREMmQm2hXimp8JUmNTLnu9KyDkTHneoCPDnKn7zbh54i2M
         ff6NfiDAH/5m2SLNXPy4VBSUEVJNF6ppZAA7Pq7AtcVnr15BnFlCTc7tHbolvK37BzEo
         UELQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gQ74RKc+;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c1si17863454pld.418.2019.07.25.09.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:32:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gQ74RKc+;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 588B922C7E
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:32:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564072365;
	bh=FEx8+YMXwTlwW700Ru/wMMO7a93IWwCkUnavThlLs6Q=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=gQ74RKc+nG+zQVrSzj00uQEq+0kP2ShquqsOzYTcb/26cqM2WNzrF5i14LWHLCuGd
	 QD3vUjskctRWfT9SIDehuUr1HAJFg5F9s49U0xCxNGxi/r7fvG6qV/1lSvfnFdJ/Cg
	 RbE92LJRGtoFYTk7bxC+W0ppmoP44K0CR3by5cZk=
Received: by mail-wr1-f46.google.com with SMTP id c2so48245617wrm.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:32:45 -0700 (PDT)
X-Received: by 2002:adf:f28a:: with SMTP id k10mr17529201wro.343.1564072363818;
 Thu, 25 Jul 2019 09:32:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-4-dja@axtens.net>
 <CACT4Y+aOvGqJEE5Mzqxusd2+hyX1OUEAFjJTvVED6ujgsASYrQ@mail.gmail.com>
 <D7AC2D28-596F-4B9E-B4AD-B03D8485E9F1@amacapital.net> <87lfwmgm2v.fsf@dja-thinkpad.axtens.net>
In-Reply-To: <87lfwmgm2v.fsf@dja-thinkpad.axtens.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 25 Jul 2019 09:32:32 -0700
X-Gmail-Original-Message-ID: <CALCETrXW_=6sPd8gcdkZtYAmCTYhoOYMYhp6_yVd-8Wd5zYsrA@mail.gmail.com>
Message-ID: <CALCETrXW_=6sPd8gcdkZtYAmCTYhoOYMYhp6_yVd-8Wd5zYsrA@mail.gmail.com>
Subject: Re: [PATCH 3/3] x86/kasan: support KASAN_VMALLOC
To: Daniel Axtens <dja@axtens.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 8:39 AM Daniel Axtens <dja@axtens.net> wrote:
>
>
> >> Would it make things simpler if we pre-populate the top level page
> >> tables for the whole vmalloc region? That would be
> >> (16<<40)/4096/512/512*8 =3D 131072 bytes?
> >> The check in vmalloc_fault in not really a big burden, so I am not
> >> sure. Just brining as an option.
> >
> > I prefer pre-populating them. In particular, I have already spent far t=
oo much time debugging the awful explosions when the stack doesn=E2=80=99t =
have KASAN backing, and the vmap stack code is very careful to pre-populate=
 the stack pgds =E2=80=94 vmalloc_fault fundamentally can=E2=80=99t recover=
 when the stack itself isn=E2=80=99t mapped.
> >
> > So the vmalloc_fault code, if it stays, needs some careful analysis to =
make sure it will actually survive all the various context switch cases.  O=
r you can pre-populate it.
> >
>
> No worries - I'll have another crack at prepopulating them for v2.
>
> I tried prepopulating them at first, but because I'm really a powerpc
> developer rather than an x86 developer (and because I find mm code
> confusing at the best of times) I didn't have a lot of luck. I think on
> reflection I stuffed up the pgd/p4d stuff and I think I know how to fix
> it. So I'll give it another go and ask for help here if I get stuck :)
>

I looked at this a bit more, and I think the vmalloc_fault approach is
fine with one tweak.  In prepare_switch_to(), you'll want to add
something like:

kasan_probe_shadow(next->thread.sp);

where kasan_probe_shadow() is a new function that, depending on kernel
config, either does nothing or reads the shadow associated with the
passed-in address.  Also, if you take this approach, I think you
should refactor vmalloc_fault() to push the address check to a new
helper:

static bool is_vmalloc_fault_addr(unsigned long addr)
{
  if (addr >=3D VMALLOC_START && addr < VMALLOC_END)
    return true;

#ifdef CONFIG_WHATEVER
  if (addr >=3D whatever && etc)
    return true;
#endif

 return false;
}

and call that from vmalloc_fault() rather than duplicating the logic.

Also, thanks for doing this series!

