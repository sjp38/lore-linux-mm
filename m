Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54D9DC43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 09:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC63C20659
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 09:35:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cG3zM3rO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC63C20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BAC08E0003; Mon, 14 Jan 2019 04:35:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368528E0002; Mon, 14 Jan 2019 04:35:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 259D38E0003; Mon, 14 Jan 2019 04:35:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F313A8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:35:05 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so19299078iom.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:35:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Pn0/rZ2B5GkSLOkvstRq19Y+ZB+KVKjQ5D4UTrTEcFQ=;
        b=cGX65EU0xahjhYuRgC9suyy7fynXWl85qk8vyxHSocFyDptZp1I+kOvXwSEbPzFcFu
         jJ9IYphX6r9sP2g+KIbMPtC9JBma/UNnoi41wqnDaOpZGBhFguCcDWxPP4jUQW2xI8zC
         FpFEfL6sac/CE001Papw+IixIZenG2XpnpryPFD1NT/lT9yK02YQ2Isa7iRGyscVA31/
         jCJnsv+Y1FaPmOhn5KM8VguonLSOQ8pnMpv+5Pa8jcIrf34bx8IFN1cmatWmA0L8nck9
         oXk24Bu7zWIbE5x9ZQzn6c7mRY2xeJ2Wz9Ry62DKbeXt9rweolP1kjt3KexyBCp0USau
         2G+A==
X-Gm-Message-State: AJcUukee774BC4H1uXSlAtEsQOXloyQoWYzg2zMsbCt3TCqFs1v4nr4e
	IGFSeiejgvPrscOGTqRsiEE/TFEnWBnwNpkg1rWoQu29g9ZWQtv0uJelkKcqMG6K1x4CYrnt7XK
	5JD2It/RNDZphDF9kHvTwvLG4wmT5C/ix7U1e5Vy0xDiseqK4d0NFeefzWwtA5p3pptQ96xSb8K
	S2BS87De+kltc8xwWUPc1Nprc7Nrx+w34g0RmawvwZd9qcFvJJxYcpPF7BHbso78vxepTymCFZd
	sgANqrTcZU702qUIVR/Vv/wax7oYBmgPoF7kdNM2ZDMFXgy/HS465+TzHsusTTkuKvM0gokAaVY
	4swafp0eMkt27ACo6Zg+mhu0LprUTeNHlW95FEaA2Jvdsib3WEFdfKRlhOuYnzRlnW4w6M/w1gL
	B
X-Received: by 2002:a05:660c:74b:: with SMTP id a11mr7294305itl.27.1547458505761;
        Mon, 14 Jan 2019 01:35:05 -0800 (PST)
X-Received: by 2002:a05:660c:74b:: with SMTP id a11mr7294286itl.27.1547458504963;
        Mon, 14 Jan 2019 01:35:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547458504; cv=none;
        d=google.com; s=arc-20160816;
        b=n+zZNfK983rVjdFjxlOIk1TlGJr9m1QrmVSQOxFbBmgjcHvX07WMneijx3QqDIpw8v
         9xz3M8KbVuCIhrWuhMQIowE67xYNupXXHDWWxn1oYOVmRtPrhjxuc+azclUuCHAYhU2u
         FB5LaP0XJm+8S4NwMhjCzB+cUCkCnlyR0/XZRF3W47RZVm5q/KtHtzd3vjd2r5qVSLeV
         ItHOB/hqM02k3QCi0PxUeqZOtRmK/guxV48PtycjWEhdKyoGcEAtZlpc3Bfly8tYIOCc
         1pPKoDAUdihdcsTrZS9a57MTNHAAY5cqVYuD50WPOerIybvkytXgwV6Ocl3NST4OOva1
         EAag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Pn0/rZ2B5GkSLOkvstRq19Y+ZB+KVKjQ5D4UTrTEcFQ=;
        b=EQIXso5FkSy4Aww1wmLwGjAqNhQ/pE667fljHLuSwjT7mx5HB3ocmKtwN92LzDZnn6
         I5BRJBzpgUt0jS7LcrnDHCir3N4FKDtXZWACBRVHtsGjYcFkbveknrYkau0ovyqRQcdT
         OAEIc8UM/TvwVCyyqXiulzs/kgJNTCWL3OKK+fn8JeAwopTB8ZVdLQZ1NOL1ZdlRI+9I
         MAhFjVXePx2lZ6ZSsovUhbC5SUKqUcc2+nSO4HYLyeMV6P9HHIF9tHE8LiviDULOk0q0
         QZBPEQ9UZaax4q333EgxGNjnzAQoFpWgRBstig9xy+V4Li8lgOKpfLD2JFBEvRTuC0lV
         GY3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cG3zM3rO;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor47489318iol.132.2019.01.14.01.35.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 01:35:04 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cG3zM3rO;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Pn0/rZ2B5GkSLOkvstRq19Y+ZB+KVKjQ5D4UTrTEcFQ=;
        b=cG3zM3rOJqP9xq8n8LMwEKTXJUQ4xh2O+zaaNyos6gkTdiT0UhD5YRj4zebrVQCK79
         lTszCU7lJZs+wRyNh/NZEjWDrwgO2XiRVx6xv0Ra/FQU9iclaLSOhmErIuO/HUVBzWr2
         nP3swD1jtKwthtzn03IXwPV9QFMWMIlVuHp1iQ0d6KMQztjWe8TBkSZdAUMrRjMh6WUN
         nStPiAZ/dUsrozxjVmfHco6C7wBa+7K1swBrAUHWvFubg/nw/9+fY4NJgHI7e9+NBb5/
         WSU1YAmgtOKm2strY0meX98AhNuQy8M3JmpV81bLo/b6PGT3C4i+VArU5y5WdeeW+yk+
         q0SQ==
X-Google-Smtp-Source: ALg8bN4Izjtfz8Gtik6EdgfSYlWSdQko5wrdsb98M1TQUO3p0k+tlZJCo9+xkTjkJb9IBNvEfs6/1WGPTInaXLkvDLg=
X-Received: by 2002:a6b:fa01:: with SMTP id p1mr9451772ioh.271.1547458504276;
 Mon, 14 Jan 2019 01:35:04 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547289808.git.christophe.leroy@c-s.fr> <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
In-Reply-To: <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 14 Jan 2019 10:34:52 +0100
Message-ID:
 <CACT4Y+aEsLWqhJmXETNsGtKdbfHDFL1NF8ofv3KwvQPraXdFyw@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	linuxppc-dev@lists.ozlabs.org, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114093452.VNIHcTvhQwIw21CfEz06HNKSQnqNYJFrQypt67scznc@z>

On Sat, Jan 12, 2019 at 12:16 PM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
&gt;
&gt; In kernel/cputable.c, explicitly use memcpy() in order
&gt; to allow GCC to replace it with __memcpy() when KASAN is
&gt; selected.
&gt;
&gt; Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
&gt; enabled"), memset() can be used before activation of the cache,
&gt; so no need to use memset_io() for zeroing the BSS.
&gt;
&gt; Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
&gt; ---
&gt;  arch/powerpc/kernel/cputable.c | 4 ++--
&gt;  arch/powerpc/kernel/setup_32.c | 6 ++----
&gt;  2 files changed, 4 insertions(+), 6 deletions(-)
&gt;
&gt; diff --git a/arch/powerpc/kernel/cputable.c
b/arch/powerpc/kernel/cputable.c
&gt; index 1eab54bc6ee9..84814c8d1bcb 100644
&gt; --- a/arch/powerpc/kernel/cputable.c
&gt; +++ b/arch/powerpc/kernel/cputable.c
&gt; @@ -2147,7 +2147,7 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
&gt;         struct cpu_spec *t = &amp;the_cpu_spec;
&gt;
&gt;         t = PTRRELOC(t);
&gt; -       *t = *s;
&gt; +       memcpy(t, s, sizeof(*t));

Hi Christophe,

I understand why you are doing this, but this looks a bit fragile and
non-scalable. This may not work with the next version of compiler,
just different than yours version of compiler, clang, etc.

Does using -ffreestanding and/or -fno-builtin-memcpy (-memset) help?
If it helps, perhaps it makes sense to add these flags to
KASAN_SANITIZE := n files.


>         *PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
>  }
> @@ -2162,7 +2162,7 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
>         old = *t;
>
>         /* Copy everything, then do fixups */
> -       *t = *s;
> +       memcpy(t, s, sizeof(*t));
>
>         /*
>          * If we are overriding a previous value derived from the real
> diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
> index 947f904688b0..5e761eb16a6d 100644
> --- a/arch/powerpc/kernel/setup_32.c
> +++ b/arch/powerpc/kernel/setup_32.c
> @@ -73,10 +73,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
>  {
>         unsigned long offset = reloc_offset();
>
> -       /* First zero the BSS -- use memset_io, some platforms don't have
> -        * caches on yet */
> -       memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
> -                       __bss_stop - __bss_start);
> +       /* First zero the BSS */
> +       memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
>
>         /*
>          * Identify the CPU type and fix up code sections
> --
> 2.13.3
>

