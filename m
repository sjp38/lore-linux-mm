Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 820A8C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:51:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C2A8216FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:50:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rHgPeR5E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C2A8216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA7B6B0005; Fri, 17 May 2019 09:50:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65AA16B0006; Fri, 17 May 2019 09:50:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5496F6B0007; Fri, 17 May 2019 09:50:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33C816B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:50:59 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id y70so1461346vsc.6
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:50:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Tu/XZ8WyPQtcgBo1xp6f5SWrU4YW1BvieV2uRJevOns=;
        b=QyTIC5gsdPKVV99wrLQ5NcWozST5Nv0ePw6Ek8Oxb5VuSwOC+FkiU0EF7Sov9/4UJS
         7AwDcBbQd1IQ+2GlzNs5W5tjZDq8RNcaP2Tb7GDhuWTk/LskzvL7jywu83FKaN9W/Qa9
         aRqBi52KIQ7yu2y7QnmTKq0zfvXK2Aqcfp5no6UmLNQS1lYemP6HolF3z31cw1VvMeW6
         yQv+lBs5PyjDy9zbT+rsydm7AI1WSeWdolXdXbu3MLp2zj72B3Dq3opBNIvBTXWhIjyK
         YF/EU3BVljlaLwAbg7lXZcZfBsSwyaZWcI5omrOKCKtl6yrOSDpuKLx9kPtbPbYtG7Pc
         Clxw==
X-Gm-Message-State: APjAAAWM6kw5IQ/dW3rpXyC5ypXDNovKKOTuZqMVCjgcIVBbnDJyRVIa
	JLipMO9mDH1Z11EBGCpH/LpYWs1en8xjoAiE4TZsjPVyGDKFj+OZjpJqGugXrX8LVlpNMkV3CrU
	YSagxBbI6v9vccNRRBtOPVh6QSjQCvtn/BHEuI0CY6oLVt1gPvOiCmQzz2Iy+PH56TA==
X-Received: by 2002:a67:e1d3:: with SMTP id p19mr14626283vsl.183.1558101058960;
        Fri, 17 May 2019 06:50:58 -0700 (PDT)
X-Received: by 2002:a67:e1d3:: with SMTP id p19mr14626258vsl.183.1558101058268;
        Fri, 17 May 2019 06:50:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558101058; cv=none;
        d=google.com; s=arc-20160816;
        b=BCaKWGqOWToHdZqaG9yNdzW3LdRByYm9SJumTw6ddV+Jir223Bu2Z6yxsqgYi6wc2A
         mkIK7EsU2WFquqhYHexKUxHoZJ49W6FKuWRq2CPjdawF8busBfDQP5H4lNPPx9rb+dwM
         HinnflAaSKIZZk/C3IUrk0z8LBP0EANnseMw6AVIw7AUx6cMxg71woJzRp+LclwV5jRS
         rSMwO0uxPDFgWkym7V4OVoDrIE43xb5XSbVcmnTcMcqpSsjVoFuS6qQBoQkarvN2AgpF
         nCVWx6Lw2DWSWam7i0Dcz8wM+UW719XSv+cQ6ShwyabWMgYapDnmvM/8L9vf7/nevHEB
         fIIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Tu/XZ8WyPQtcgBo1xp6f5SWrU4YW1BvieV2uRJevOns=;
        b=0S3vqjsNywXhySh+qIBswyoYz7BOzFE7/HZHx8SmyPaW7nMjdMLyI4Qe251houJ5Zb
         fdoE2bYafTWV1aoExrCGfMyRn2V2Ye8y8pV16WhqM4Bbsdeu488cu07sDmht4avmgXWA
         pOpJG2AACaShE4S12cxvlS1fJDQU5bQQDwUVI7husIIxm8IQQPXlDPHGjMRdLhv1IuTs
         /NBvdTkwr0MgsH2TwtcVx/bZT/++TFCKr9ibUy+GR7mA+ENMEaep3BeHfH0WQjJ5Zpw9
         t3f0NKpTiQrIgjxs0b8lBQQCY0qRtseQDLb3vyGtJg0HGmo8ADmIuLo2+6nc8NGuRGbj
         X+zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rHgPeR5E;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor4206293vsj.63.2019.05.17.06.50.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:50:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rHgPeR5E;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Tu/XZ8WyPQtcgBo1xp6f5SWrU4YW1BvieV2uRJevOns=;
        b=rHgPeR5EkFNJw0Y3h/Mnc5B3YIjO3Y1YYz70lHZ/6bNSNruCgaPJ0q8vYl/adsMLdX
         6iGuqKG17GHfn8zZ2HIXYYhWBfrZgQINJdBu+zSuSI9NwS65IwehTsTyUc7/3k8Vkglr
         O5/HdvT3rb5yihdqKcJ/D87syAkfpLR+oHBxCN3SDwir5YfLhI9mTTRDGvX5uO9vf31h
         1ivJ+m9a+DiI3PIwR23gsHmVNAamQVcnymqpKtqNP8EGv7pM7MT36U/02a40FBAIJekh
         8SHU3k8q5I4KA/DxLizSAy0Q2nPp9H+6y9jFSYcJK/6tZ9gjsyCiX0i4aSlumrcdhjy4
         nyIA==
X-Google-Smtp-Source: APXvYqz/GeQC7brtsyxMaawY3Pnb522oTj0eF7F0BnKqrc45R8aoK2BmfjgDo8jGr/SCpZm4mSpV/UmZRTjKjXaJ8tI=
X-Received: by 2002:a67:7241:: with SMTP id n62mr4234300vsc.217.1558101057477;
 Fri, 17 May 2019 06:50:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-5-glider@google.com>
 <201905160923.BD3E530EFC@keescook> <201905161714.A53D472D9@keescook> <CAG_fn=Vj6Jk_DY_-0+x6EpbsVh+abpEVcjycBhJxeMH3wuy9rw@mail.gmail.com>
In-Reply-To: <CAG_fn=Vj6Jk_DY_-0+x6EpbsVh+abpEVcjycBhJxeMH3wuy9rw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 15:50:45 +0200
Message-ID: <CAG_fn=VqXVEi_W0VDpZKYgBh831JADPRFPRmYR=1ApfuO+7HQw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff allocations
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 10:49 AM Alexander Potapenko <glider@google.com> wr=
ote:
>
> On Fri, May 17, 2019 at 2:26 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Thu, May 16, 2019 at 09:53:01AM -0700, Kees Cook wrote:
> > > On Tue, May 14, 2019 at 04:35:37PM +0200, Alexander Potapenko wrote:
> > > > Add sock_alloc_send_pskb_noinit(), which is similar to
> > > > sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
> > > > This helps reduce the slowdown on hackbench in the init_on_alloc mo=
de
> > > > from 6.84% to 3.45%.
> > >
> > > Out of curiosity, why the creation of the new function over adding a
> > > gfp flag argument to sock_alloc_send_pskb() and updating callers? (Th=
ere
> > > are only 6 callers, and this change already updates 2 of those.)
> > >
> > > > Slowdown for the initialization features compared to init_on_free=
=3D0,
> > > > init_on_alloc=3D0:
> > > >
> > > > hackbench, init_on_free=3D1:  +7.71% sys time (st.err 0.45%)
> > > > hackbench, init_on_alloc=3D1: +3.45% sys time (st.err 0.86%)
> >
> > So I've run some of my own wall-clock timings of kernel builds (which
> > should be an pretty big "worst case" situation, and I see much smaller
> > performance changes:
> How many cores were you using? I suspect the numbers may vary a bit
> depending on that.
> > everything off
> >         Run times: 289.18 288.61 289.66 287.71 287.67
> >         Min: 287.67 Max: 289.66 Mean: 288.57 Std Dev: 0.79
> >                 baseline
> >
> > init_on_alloc=3D1
> >         Run times: 289.72 286.95 287.87 287.34 287.35
> >         Min: 286.95 Max: 289.72 Mean: 287.85 Std Dev: 0.98
> >                 0.25% faster (within the std dev noise)
> >
> > init_on_free=3D1
> >         Run times: 303.26 301.44 301.19 301.55 301.39
> >         Min: 301.19 Max: 303.26 Mean: 301.77 Std Dev: 0.75
> >                 4.57% slower
> >
> > init_on_free=3D1 with the PAX_MEMORY_SANITIZE slabs excluded:
> >         Run times: 299.19 299.85 298.95 298.23 298.64
> >         Min: 298.23 Max: 299.85 Mean: 298.97 Std Dev: 0.55
> >                 3.60% slower
> >
> > So the tuning certainly improved things by 1%. My perf numbers don't
> > show the 24% hit you were seeing at all, though.
> Note that 24% is the _sys_ time slowdown. The wall time slowdown seen
> in this case was 8.34%
I've collected more stats running QEMU with different numbers of cores.
The slowdown values of init_on_free compared to baseline are:
2 CPUs - 5.94% for wall time (20.08% for sys time)
6 CPUs - 7.43% for wall time (23.55% for sys time)
12 CPUs - 8.41% for wall time (24.25% for sys time)
24 CPUs - 9.49% for wall time (17.98% for sys time)

I'm building a defconfig of some fixed KMSAN tree with Clang, but that
shouldn't matter much.

> > > In the commit log it might be worth mentioning that this is only
> > > changing the init_on_alloc case (in case it's not already obvious to
> > > folks). Perhaps there needs to be a split of __GFP_NO_AUTOINIT into
> > > __GFP_NO_AUTO_ALLOC_INIT and __GFP_NO_AUTO_FREE_INIT? Right now
> > > __GFP_NO_AUTOINIT is only checked for init_on_alloc:
> >
> > I was obviously crazy here. :) GFP isn't present for free(), but a SLAB
> > flag works (as was done in PAX_MEMORY_SANITIZE). I'll send the patch I
> > used for the above timing test.
> >
> > --
> > Kees Cook
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

