Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22CA2C04AB2
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:43:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C978E21019
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:43:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="W5NPu7UN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C978E21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6302B6B0003; Thu,  9 May 2019 12:43:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 606D56B0006; Thu,  9 May 2019 12:43:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A82A6B0007; Thu,  9 May 2019 12:43:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 286B46B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:43:35 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id w84so1185851vkd.23
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:43:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=scoklaUKCwoyF6C6A+2vS8qnRMGu4PDFVwRfwqNtv98=;
        b=qix4g2LhtKIJvSl25Cq8dyczKx/wz4HHAQjv+O06mXtLYeEjdhoeqPGfzXJAwEiwx8
         JCsr5VNpi1f4SJv2t3k9GsBwHUNNyS34FK7SPKEYugUWyommSJwrO7nVyEfKAb5EKfJo
         rim5ZVdKJ1DlZz8bg2t8mjxHmOVNzuL119/VGSOws1ghkXVZqDJ+8RL2HlNR/zCea9QC
         aN2NkadfALWA1J4YZKl9fdD0rZa1/PFsw3fBW2A7Um20WFk3zKnREjpZlN2pMbkPDEoV
         DQHCof99lkGVyRT/PUtLnPoS71laatsJukCBLwqs1XVM5WZMK2LrvSNot3TW8bTdKwLS
         mhsQ==
X-Gm-Message-State: APjAAAVuLOxKGxrA2vwHHy4fYCkEF4SyTkhs+6RQ6mJN6c2jrzFQizCx
	DPBSRpG8qRJqk6RFyptnDXoeBkQHRUMO8liGFEavItyvbu2DpZKqcnyFHSe8S5Cb98mOe0ntf3e
	6oB8vMdaxBulEhe1qvZIEodod2dlurTHi6oiFh1LchbljDeKBLVPjpzpppkOGc0w8Mg==
X-Received: by 2002:ac5:c542:: with SMTP id d2mr2247596vkl.57.1557420214835;
        Thu, 09 May 2019 09:43:34 -0700 (PDT)
X-Received: by 2002:ac5:c542:: with SMTP id d2mr2247563vkl.57.1557420214110;
        Thu, 09 May 2019 09:43:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420214; cv=none;
        d=google.com; s=arc-20160816;
        b=Fiw/IxQKu32OWiFkKN07lJ/k1spcLL6lZHYyGNrS4rXrmcsASId+CFHwUFeXcIrhBj
         gVHhGY4HUZminpJ/tg3sxzqRr7oz+5NCAT/7C4EZFKLjtVt+BilAETGN8U2ohn7B4DFO
         LeBcNM2SyDmduVsTCNt1dNGUcfuLJUUB3QBeno29iSmb4XV2hfi+bGiwIIkRE5sQUWJa
         HjZGBH0y097si8onSeJf0+ylw6ShhzI1NSLaghP+ep4BrIUOCI2NBWX8p6hytbxrR/Jr
         WvalwyeHbymbAu3bjHE21WcOflS00uMpgpLuWmwsp9yEa2OqFvsVRX7r/NT9pAAstzWl
         Xskw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=scoklaUKCwoyF6C6A+2vS8qnRMGu4PDFVwRfwqNtv98=;
        b=kG5iRfZppkeCcgS68eAsgQ6UF5jY+MRYveBT5FdRfLOwr7PbSuEhyhvGnMor6C/SBW
         UTjupX67kan6MJUYnUfWVu6dsDgRqLsU2lY73vyes+L8FcCFA1h55eFiTkwJ8gycPkwd
         RDMMM1Z5mU3x70D4xt4KeZ7t8UfuCqXWGY5sAFsyVqVAgIDja64ehP46QXvz+kC245y2
         UXnxCQnFqqgQi5zCFj0AVBXfyjTXJa9NCpE5S2+wLl+t1vuIBuLCgOrb9n1tDq4hkbQe
         N36qzVCRwW9rrmhK6Kngs+cF53BaH1wqfsfeK40Ov2uZGnrlOZIwoRQiQJxmV8paNbxb
         z7TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=W5NPu7UN;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor955928vkd.5.2019.05.09.09.43.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 09:43:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=W5NPu7UN;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=scoklaUKCwoyF6C6A+2vS8qnRMGu4PDFVwRfwqNtv98=;
        b=W5NPu7UNCMvXR4FF+Orajnb/B6NZxQzAvi9Rnniu5D1QBMIj1zEd1ZOTFs7N0YCb4h
         obNz04dmCAXeV8V10GEaxiDmcRhVkfNt0Sm9pD4dYF/C1vabNRy4tyw/q7pPU4tQMNfr
         KhlKXF2buBmjsDZq5ypkF3nP3KBRvADS4tobRjqeogywxqaPTtWxqDz5C5JWDdqIo4q9
         nGlCgGUJ8Vitujn2OgVQsAdeVHSP6yhMv9Ya4xWGm4t8jYixlVweNEFJSk9DnlVnYaO1
         kTMxqWZfeq5kV4no0PIgvREzErEcSEXQqIUq8unew+2G0z3iFWyYgkfqg9umSa6KielS
         6rXg==
X-Google-Smtp-Source: APXvYqyCrNILIPE1aM9yj+g5z6EqLOv3bZuyYJ/RoOpitBlKLPTF4cJxqZd//NaX8Rp91mG9W2FyALdArcIfwkl6nKs=
X-Received: by 2002:a1f:ae4b:: with SMTP id x72mr2336739vke.29.1557420213429;
 Thu, 09 May 2019 09:43:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-2-glider@google.com>
 <CAGXu5jKfxYfRQS+CouYZc8-BMEWR1U3kwshu4892pM0pmmACGw@mail.gmail.com>
In-Reply-To: <CAGXu5jKfxYfRQS+CouYZc8-BMEWR1U3kwshu4892pM0pmmACGw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 9 May 2019 18:43:21 +0200
Message-ID: <CAG_fn=UDyVpZz5=oP4HHdYCB43NnXG1sLypRXopyEk9qgq471A@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Kees Cook <keescook@chromium.org>
Date: Wed, May 8, 2019 at 9:02 PM
To: Alexander Potapenko
Cc: Andrew Morton, Christoph Lameter, Kees Cook, Laura Abbott,
Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland

> On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.com> wr=
ote:
> > The new options are needed to prevent possible information leaks and
> > make control-flow bugs that depend on uninitialized values more
> > deterministic.
>
> I like having this available on both alloc and free. This makes it
> much more configurable for the end users who can adapt to their work
> loads, etc.
>
> > Linux build with -j12, init_on_free=3D1:  +24.42% sys time (st.err 0.52=
%)
> > [...]
> > Linux build with -j12, init_on_alloc=3D1: +0.57% sys time (st.err 0.40%=
)
>
> Any idea why there is such a massive difference here? This seems to
> high just for cache-locality effects of touching all the freed pages.
I've measured a single `make -j12` again under perf stat.

The numbers for init_on_alloc=3D1 were:

        4936513177      cache-misses              #    8.056 % of all
cache refs      (44.44%)
       61278262461      cache-references
               (44.45%)
          42844784      page-faults
     1449630221347      L1-dcache-loads
               (44.45%)
       50569965485      L1-dcache-load-misses     #    3.49% of all
L1-dcache hits    (44.44%)
      299987258588      L1-icache-load-misses
               (44.44%)
     1449857258648      dTLB-loads
               (44.45%)
         826292490      dTLB-load-misses          #    0.06% of all
dTLB cache hits   (44.44%)
       22028472701      iTLB-loads
               (44.44%)
         858451905      iTLB-load-misses          #    3.90% of all
iTLB cache hits   (44.45%)
     162.120107145 seconds time elapsed

, and for init_on_free=3D1:

        6666716777      cache-misses              #   10.862 % of all
cache refs      (44.45%)
       61378258434      cache-references
               (44.46%)
          42850913      page-faults
     1449986416063      L1-dcache-loads
               (44.45%)
       51277338771      L1-dcache-load-misses     #    3.54% of all
L1-dcache hits    (44.45%)
      298295905805      L1-icache-load-misses
               (44.44%)
     1450378031344      dTLB-loads
               (44.43%)
         807011341      dTLB-load-misses          #    0.06% of all
dTLB cache hits   (44.44%)
       22044976638      iTLB-loads
               (44.44%)
         846377845      iTLB-load-misses          #    3.84% of all
iTLB cache hits   (44.45%)
     164.427054893 seconds time elapsed


(note that we don't see the speed difference under perf)

init_on_free=3D1 causes 1.73B more cache misses than init_on_alloc=3D1.
If I'm understanding correctly, a cache miss costs 12-14 cycles on my
3GHz Skylake CPU, which can explain explain a 7-8-second difference
between the two modes.
But as I just realized this is both kernel and userspace, so while the
difference is almost correct for wall time (120s for init_on_alloc,
130s for init_on_free) this doesn't tell much about the time spent in
the kernel.

> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

