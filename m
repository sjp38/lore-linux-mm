Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9659C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:33:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4E17218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:33:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R2ww8ncy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4E17218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B4AF8E0002; Thu, 31 Jan 2019 05:33:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363038E0001; Thu, 31 Jan 2019 05:33:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27A5E8E0002; Thu, 31 Jan 2019 05:33:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00BEB8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:33:36 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id b14so2144164itd.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:33:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=R5OCV2eb5TSImT0OCdqMh36XZu7SuJl/MJd5OK0pMpw=;
        b=p1hmZwVnwpbruOgdd4XC7ai7iJOK/5kfIospTOUUR8smdWHu5U8b8Jy/Zf3ELFUxY2
         GWgPzPwYs+UeGZ3biznce1D/CQlPDm3yexxvNil3Wbx3OC2TMnCDW46GpAJ17w4lMbRt
         tSP5QU3Gcngj8uDi6sMB7fI4uJktT6WbHgdgxLASoy6Dni/mluEustUyRUnz9IkC9gjf
         o00A7Nz2tDaZKpWaBv9xIjijO3YcEYNa2lwnKeLo8NPvZlyh+I9OUomZt8J1AnDPOQdL
         L444/CFd+ZiaTG4O8wPZsVz+c/FzS2snDVnynushnjtLDqSumHBy7tVr6joshLqGRBs9
         Nusg==
X-Gm-Message-State: AHQUAuZY4UMniipV9Sy3t8oYN17C4+uqj1MfWPxltyeD21WDe9r50Emo
	LUVo+gqHRr6QlULHiJZUO1hbhjC4w9g5u0gh1axMpTFjGsEVZX4sU9ZkHYALghPTdZJCYLHu87Z
	jxw9PYHA/OpIUFVm+R0jtrCclC21UWkGAxlfBL9EVMkm7G3pcNs9tvuCjAbDzR2j8FY9TQebXVK
	8n33krR8MKQS5kQ/R9PMydkK2qCcW8UR3ASPLtB0lwBRbHZ8wR17gD+ztVoGEjwWH+OXzYkUSL9
	VwwlYfsIzvzXgwAB3/XB6RNY4Tv0Fb9irCbz+Q4x0kchbWJbb9B1NRkikSKsC9JfAiHpcM6N0d3
	hkOdj2tj3GF5BRCptOhqxJ1WkwwO3XuDvUDjINH/9VTf4a9IDJ4vJRXevYCAKbKIkT05BBS9jxc
	f
X-Received: by 2002:a6b:8f08:: with SMTP id r8mr20614901iod.56.1548930816670;
        Thu, 31 Jan 2019 02:33:36 -0800 (PST)
X-Received: by 2002:a6b:8f08:: with SMTP id r8mr20614885iod.56.1548930816059;
        Thu, 31 Jan 2019 02:33:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548930816; cv=none;
        d=google.com; s=arc-20160816;
        b=Lw1f0Vcv3YL2dyBBzHvzcuEtw0rDtwC++zMfZqLdKAZty/SdodFXDGtXiuCo18Ma/p
         mXWaGD8jfnQA4EsImnnMTvRlwEn1jdRdA07ADvWeX0Zi/vp7N4yZy5R5WrZC5CsaPkkd
         NvcNkIkjxSg0UfbBEwpkShDAFY4WRWhxcDQFSYJ8zjir8rCS9owWO12zwicsF6NhVwmZ
         29xl9wpJjvyB0tE1SL7VZ6+NWnODzaSAC3ZFOfG0i8eRUDqYefAaTIhaU1Wx+3ob3GXN
         P+mLiH6O6FgIMp6HCbebxTlO6vbaXpkNcmmpLZLTLXRWXVDau4H4ZUCMzDBcRK/sC1x1
         /MQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=R5OCV2eb5TSImT0OCdqMh36XZu7SuJl/MJd5OK0pMpw=;
        b=rCIWBOiSDEh0kGYgBjkh96gJU5S38Trp5G4Nb00BOjsGai20XHN1XVg1rjyhZKi0Pe
         RYCrdUnfUggoT603xtvqDrbhE8oIthO4z2622YrDScew7N389DILLTHg9QtnBQMLMv4X
         yBbOltxnCan8tuwTGNMK+GK525ezcXS9ktYrnvk6zMBNWVHUb8nDmR8DXJ3s5/1mIhdi
         HyQF9/rIOUerIm+G+U9Mn+T8c856W6cVDqxH7G48GlkslA6h5qI0brBjO+Q29XuFyLyz
         n/YmJqqABO/GRn8ltug7XDTA4htO8bnGXRtDctV6iTPonicTiRvXZc7CxXjDtAbEYMtY
         QgKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R2ww8ncy;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 72sor7815866itw.3.2019.01.31.02.33.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 02:33:36 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R2ww8ncy;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R5OCV2eb5TSImT0OCdqMh36XZu7SuJl/MJd5OK0pMpw=;
        b=R2ww8ncyawJIWFf8Q5ydNy6tXXRHcFWBVkR7BPPiuTMYYZ6hZnE8t+oNIWkXzKslao
         QK2QA+nlrVf/48Ace5I+FbgGCB0y0xFkRjhflY22ydOgpTH95t42Isk05+8m85l4Qu85
         08+SaInSgNm4zQsoZOoWlCEGNnKCfcI1i/GstDVo0Q9wkqzJLKEYTBDfgGu/rcXaCA5N
         au79HEP2JQlS105xIjXjDD17uUYGrZs25oNtEdlvZZguiq1LXr6Te4FD9tp0GrAoMdxb
         RocOc/LL8cBOuxaQp6W9VUWAxSgOfcI8vz9EQLysTO8eVIR6HqA5DyDBn0OMSlQttMPr
         ly7w==
X-Google-Smtp-Source: ALg8bN4SyszOI3ZUPf/49Jon29rSWSKs3cEA3J99dXanmp0TNW3+sAb4Sb29BA3ZWQPqhLLMCUSFF/vRP7c1dMl3hl4=
X-Received: by 2002:a24:6511:: with SMTP id u17mr18444334itb.12.1548930815368;
 Thu, 31 Jan 2019 02:33:35 -0800 (PST)
MIME-Version: 1.0
References: <1547634429-772-1-git-send-email-elena.reshetova@intel.com>
 <20190121123836.GC47506@lakrids.cambridge.arm.com> <CACT4Y+Y6JNyQ+SSZXDSYVcBXZ_e1Hf3OMpoz=1eqGNhNKqYikg@mail.gmail.com>
 <2236FBA76BA1254E88B949DDB74E612BA4B9BBF9@IRSMSX102.ger.corp.intel.com>
 <CACT4Y+Y5Y54iWn3w2jifjecDb+dZa_B=qZBsKTH8immHktij2Q@mail.gmail.com> <2236FBA76BA1254E88B949DDB74E612BA4B9BC4B@IRSMSX102.ger.corp.intel.com>
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612BA4B9BC4B@IRSMSX102.ger.corp.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 31 Jan 2019 11:33:24 +0100
Message-ID: <CACT4Y+bboJysvOc2d2z7qTqyPR+2mjK3AGxC0nnp8kbGWqcuZQ@mail.gmail.com>
Subject: Re: [PATCH] kcov: convert kcov.refcount to refcount_t
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Anders Roxell <anders.roxell@linaro.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>, 
	Peter Zijlstra <peterz@infradead.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 11:09 AM Reshetova, Elena
<elena.reshetova@intel.com> wrote:
>
> > On Thu, Jan 31, 2019 at 11:04 AM Reshetova, Elena
> > <elena.reshetova@intel.com> wrote:
> > >
> > >  > Just to check, has this been tested with CONFIG_REFCOUNT_FULL and
> > > > > something poking kcov?
> > > > >
> > > > > Given lib/refcount.c is instrumented, the refcount_*() calls will
> > > > > recurse back into the kcov code. It looks like that's fine, given these
> > > > > are only manipulated in setup/teardown paths, but it would be nice to be
> > > > > sure.
> > > >
> > > > A simple program using KCOV is available here:
> > > > https://elixir.bootlin.com/linux/v5.0-rc3/source/Documentation/dev-
> > > > tools/kcov.rst#L42
> > > > or here (it's like strace but collects and prints KCOV coverage):
> > > > https://github.com/google/syzkaller/blob/master/tools/kcovtrace/kcovtrace.c
> > > >
> > >
> > > Ok, so I finally got to compile kcov in and try the first test program
> > > and it works fine as far as I can see: runs, prints results, and no WARNs anywhere
> > > visible with regards to refcount_t.
> > >
> > > I did my test on 4.20 with CONFIG_REFCOUNT_FULL=y
> > > since I have serious issues getting 5.0 running as it is even from
> > > the stable branch, but unless kcov underwent some serious changes since
> > December,
> > > it should not affect.
> >
> > There were no changes that should affect this part.
> >
> > Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>
>
> Thank you! Will you be able to take this change forward as for
> other normal kcov changes?

Andrew, please take this patch to mm tree.

+linux-mm mailing list for proper mm patch tracking
I am not a maintainer, all other KCOV patches went through mm tree.

