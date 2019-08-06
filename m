Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD28C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A156C20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:51:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="MlysRV02"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A156C20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F5EA6B0003; Tue,  6 Aug 2019 14:51:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A65E6B0006; Tue,  6 Aug 2019 14:51:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BCBD6B0007; Tue,  6 Aug 2019 14:51:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEE666B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:51:03 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e14so17780592ljj.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:51:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YFrdn8TjmQNSnIaAcCuqbEzq3mrXCDg59WKear6Xdpg=;
        b=AosiePcxzR5VOcaw1njVRez8LTjfgMxbnvhfyMY0I1Mi48HkZiwVUeVknE/ygtlXrn
         wsYuX1FRU7TPsqvLmzo9prd0/y/mjEBnhgFW3xPiyR41/a4LbFrTMjGRf0uApQ29adgW
         +Cf56hUucANs/ofpdkzIvI6N+lqA/Trr+hSZk5ji5wC7/rS6bzFeOXjSCN1pxexk6+pR
         Q4TM25UH2buxfyLPmF5Ytj78EnD+54khxORQaksjD9ZU878VOFKmUHzh4wt4V6+h8JhI
         kPy2amMdXEf9AvqXnbx4mUWvujoH/BPhJMEWtxow3yPVabSo5X0I8CViQ64/QlCyWjFN
         UVJw==
X-Gm-Message-State: APjAAAViMTlBsgg9T5OjbqwJ5C+sr70Q8RndesHLQxcw+YfP1grViyYW
	gLybJNyTEc+uXf6BGIFGkyS7DOVKIy/nD9F304Qg2rMlvefAeYbLp147oZKMKwvzW3NtdnC+wCB
	vnpEf1SlZ0PqA3M+SvWZumUNhpVhCu1hOf85Fyu27KzTwRqUJj1TnftnyFn2fVDbFeg==
X-Received: by 2002:a2e:8999:: with SMTP id c25mr2543707lji.169.1565117462904;
        Tue, 06 Aug 2019 11:51:02 -0700 (PDT)
X-Received: by 2002:a2e:8999:: with SMTP id c25mr2543676lji.169.1565117461954;
        Tue, 06 Aug 2019 11:51:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565117461; cv=none;
        d=google.com; s=arc-20160816;
        b=n6CnwyTS5GCo6lSGlgqef2YkEJJGwfXwd5VMjaydEj2s2ET5mBvCCHOrGEGmx9ojKW
         AzsSGXRR6gOjQHPCN+6nFwLzv1sIorFDEcHtQxBqAq0qFQ0UQ81xVj1zQRsUCB36CEWa
         arhiJGRRDZR8sHBQGzqJ4srWGqiTXujf0Mdh98FFvRBNpCKJGgyJjLTfTwUYlNunzQf7
         3aLCDMISMgQlm6Bpj1o6FwXDuSLupdCdnPRNxHHUZlPAx0V6f4k3sIh/fS/01JQFYSxF
         uG7j9FBiJ9rhUD4QOumZgx9uDsGMh88xUUjfhi9TeeLPd3yPFqDVLzHrAZujbObf5NnU
         FCMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YFrdn8TjmQNSnIaAcCuqbEzq3mrXCDg59WKear6Xdpg=;
        b=VPVGgCtyspkTVA/oaI2iZjMBz5bpBWpdJCeSRSZE3vADGCc6fK2US/JLn9Tq0Xqij+
         B6rsQuluqotd1mMYOuWk3pX1wKh+yyL2TTRQVnCcx3PrSnUSc/YM7gXEAivZTYp9j9Vt
         d31K22hb1/ZqOisFZzykpibRg9CauUsI3RsP4ekKTq2WpnZ4uzN9fchcLM/ZFEc9ph0w
         ft8Y0jwX7RYp6KfWakkJHSoRQdEJ3ahvgybkrQivGDuvASM4iTSfkV3Q0lJ465t0grMZ
         G25PRQS+PwngDdl0uWJq6SXvxI/x7dlBOE9kU3MVCHzt5Yn778953KbL62gO8XfBccgk
         FV8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=MlysRV02;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 6sor46643851ljs.44.2019.08.06.11.51.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 11:51:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=MlysRV02;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YFrdn8TjmQNSnIaAcCuqbEzq3mrXCDg59WKear6Xdpg=;
        b=MlysRV02mcMixM5P973XDGPSxckBz4Nea7C3SNGSHcfQXpMYCeOaEo4xQvZFVIgIBy
         AFFjp9IQ8QdVB/2B+8z1j1rT4dC0Ak27vpobppoYytcpWfuMnn4/z0OVQMXSAxk5j/X4
         5pVDLEKsr8UIaKS0UpizhCPTazxnvNME05Bg0=
X-Google-Smtp-Source: APXvYqzjyD9hRBQOyybXTeJHDz8sThkFpnPcNCbJ6vWYcWT7YFfOFluDWeNgg/9ayepOmlv91Z6egA==
X-Received: by 2002:a2e:854d:: with SMTP id u13mr2604871ljj.236.1565117460080;
        Tue, 06 Aug 2019 11:51:00 -0700 (PDT)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id b11sm18038184ljf.8.2019.08.06.11.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 11:50:59 -0700 (PDT)
Received: by mail-lf1-f50.google.com with SMTP id 62so57145982lfa.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:50:58 -0700 (PDT)
X-Received: by 2002:a19:c20b:: with SMTP id l11mr3479307lfc.106.1565117458380;
 Tue, 06 Aug 2019 11:50:58 -0700 (PDT)
MIME-Version: 1.0
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org> <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com> <20190806073831.GA26668@infradead.org>
In-Reply-To: <20190806073831.GA26668@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 6 Aug 2019 11:50:42 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
Message-ID: <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
Subject: Re: drm pull for v5.3-rc1
To: Christoph Hellwig <hch@infradead.org>
Cc: =?UTF-8?Q?Thomas_Hellstr=C3=B6m_=28VMware=29?= <thomas@shipmail.org>, 
	Dave Airlie <airlied@gmail.com>, Thomas Hellstrom <thellstrom@vmware.com>, 
	Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, Jerome Glisse <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 12:38 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> Seems like no one took this up.  Below is a version which I think is
> slightly better by also moving the mm_walk structure initialization
> into the helpers, with an outcome of just a handful of added lines.

Ack. Agreed, I think that's a nicer interface.

In fact, I do note that a lot of the users don't actually use the
"void *private" argument at all - they just want the walker - and just
pass in a NULL private pointer. So we have things like this:

> +       if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
> +                       NULL)) {

and in a perfect world we'd have arguments with default values so that
we could skip those entirely for when people just don't need it.

I'm not a huge fan of C++ because of a lot of the complexity (and some
really bad decisions), but many of the _syntactic_ things in C++ would
be nice to use. This one doesn't seem to be one that the gcc people
have picked up as an extension ;(

Yes, yes, we could do it with a macro, I guess.

   #define walk_page_range(mm, start,end, ops, ...) \
       __walk_page_range(mm, start, end, (NULL , ## __VA_ARGS__))

but I'm not sure it's worthwhile.

                  Linus

