Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 487D4C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:52:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AEEC20665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:52:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="YW+HL5IB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AEEC20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AA8A8E0002; Mon, 24 Jun 2019 17:52:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85B5B6B0006; Mon, 24 Jun 2019 17:52:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 772048E0002; Mon, 24 Jun 2019 17:52:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14A326B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:52:21 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l4so2542496lja.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:52:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o2TgnyjeWoDT8cizs+0926CcrBI/Czk7Q1OwFweZT40=;
        b=msiZCAkG4KczXcc5mbgUe+qOwvH5A4QoQ92UvrToFZB2XijhboLH52p+P4D+ecQx//
         +EMUE3rxhcFkyhe7bSwlRCWgxjtjP+BjdodYtnMnFaNwAaoJDcO2kauZQOsXl9++Y39E
         Plw7SXOyP3uifXDIlRuYvs03Wl05BJG69qOXvahbaGXColISgK7m7GKVWYhnx9x+ULMN
         vOkE/X/xS6qHJgMILFJ2UhB5mlkU3cJvf8jJWgTUNdHr3CR1JgJkNIKJ67ji52TX9gxR
         cIKzCPolkhSSx8k9/hNJ+PVoBGLehiaWs7i33gnMXDORMYUsD6zmOcMCfI5iND53esC9
         eVxw==
X-Gm-Message-State: APjAAAUf02t9+1UhFUemBLdF2FpOxp1D6VsIZlizIA47XI0tM4pEO7dE
	gbO7aPDUVia6ynvdHq+fkwqe/iDzjA1q2oJq+N+6V58oU5H49omv2gv6KwQtpVmnkRBltYp223Z
	OfYgyVeRanVcscb9R5/kniG6FhkIINGyYj5uAsav0lILN3pEGB+39T0iOKuDYthH30A==
X-Received: by 2002:a19:d5:: with SMTP id 204mr11843301lfa.66.1561413140219;
        Mon, 24 Jun 2019 14:52:20 -0700 (PDT)
X-Received: by 2002:a19:d5:: with SMTP id 204mr11843271lfa.66.1561413139399;
        Mon, 24 Jun 2019 14:52:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561413139; cv=none;
        d=google.com; s=arc-20160816;
        b=c2eXqQRxPqvlmIHeb2Vie6RqswboUlSn3ji5KfiyxFYOO+C9tGH9oyc7KmSt/CUpzw
         JuH1foFhhzC2YJVJQAfbAwB+t9+ZL5JPyvLxGV0UjiDpMmrUtvnYCDedzlEypob4LnY6
         6RTczosoMgCo/86eKx7mf9R3ByiRsf4xHuX7ue/U1wVuNyLtc9jTOukEasBRu6gbpu3A
         rAKbR84ZH+NnOvIMjsmnZk8VgsNl6k1jjJliq35QOJDCHPtgiAMo7okjesxxTIntwpFn
         GSgMNRuQrhUKTFKTKv452g7bjGX4Bara1j8HmVY20H1aWnndSVPv9hJyA9o79N+1k0rW
         k4Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o2TgnyjeWoDT8cizs+0926CcrBI/Czk7Q1OwFweZT40=;
        b=Y+v0iKyR2g366AGtEGbx0xh1a4ZKav/7c2siWvuiwMXUPF+RZ116EkcpPiPgBhzK4k
         +0NMiP4uOE9shN66DOqy21jBr03eg9pS/EG7gBa7O+pjq3wvhiGu3wyh09bUJVOQJ+r1
         q77rI9uTDBInwbSIvXdLdsMv6n8+3xNUnKQMjgsi6Zr60pAhgd+j2ERonPjv7BRAfMSA
         19dEUaGF4LVb1ZTr1HNk5+5KMUkFdxW5J1PqcXPueP/8fppwmt06w41zxtcFFmorVGiE
         v32mxO3DyRwmachvHgWpVyk3Cr4zxEMSlu2YAlDepbNmL9kjDQ2dQe4cZ2cIHd+aisRr
         /oNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=YW+HL5IB;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor6047177lji.25.2019.06.24.14.52.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:52:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=YW+HL5IB;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o2TgnyjeWoDT8cizs+0926CcrBI/Czk7Q1OwFweZT40=;
        b=YW+HL5IBGifOF6jZu1p6PtaguBQyhJkmQ9YMn7Jji10endO+CCULhFAsaLYdbA85HU
         bFUAnpfdTAsZ1Gvy96tlCor3QNdK05lm3AEeLiJmDqpEr3l1mXaGi+f50BoXwSjtl9UA
         vNVPNKHu+JCKTKrlQwc17yT7GYO7Y66TTo8Mw=
X-Google-Smtp-Source: APXvYqxvZBeSJ4kcoi9FjO9JOyILz08gtq6JCRIJSY8NhG9mz57f+d3xr6uxl2PM0UYCirSAnpiZ6A==
X-Received: by 2002:a2e:9a82:: with SMTP id p2mr7990343lji.64.1561413138359;
        Mon, 24 Jun 2019 14:52:18 -0700 (PDT)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id s1sm1898824ljd.83.2019.06.24.14.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 14:52:17 -0700 (PDT)
Received: by mail-lf1-f51.google.com with SMTP id r15so11102298lfm.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:52:17 -0700 (PDT)
X-Received: by 2002:ac2:44c5:: with SMTP id d5mr28053521lfm.134.1561413136997;
 Mon, 24 Jun 2019 14:52:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190524153148.18481-1-hannes@cmpxchg.org> <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org> <20190530161548.GA8415@cmpxchg.org>
 <20190530171356.GA19630@bombadil.infradead.org> <20190624151923.GA10572@cmpxchg.org>
In-Reply-To: <20190624151923.GA10572@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 25 Jun 2019 05:52:00 +0800
X-Gmail-Original-Message-ID: <CAHk-=wjcO7WjWyAoBmXDWcn7spfJbbgF_tXaHrqANVqEH8DGmQ@mail.gmail.com>
Message-ID: <CAHk-=wjcO7WjWyAoBmXDWcn7spfJbbgF_tXaHrqANVqEH8DGmQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page cache convergence regression
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux-MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 11:19 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Hey, it's three weeks later and we're about to miss 5.2.
>
> This sucks, Matthew.

Yes.

And I do think that having a real gfp field there would be better than
the very odd xa_flags that is *marked* as being gfp_t, but isn't
really a gfp_t at all.

So how about we apply Johannes' patch, and then work on making that
xa_flags field be a proper type of its own. Because it really isn't a
gfp_t, and never has been, even if there might be some very limited
and hacky overlap right now.

Alternatrively, the subset of bits that _can_ be used as a gfp should
actually be used as such, in xas_alloc/xas_nomem. So that you can do

    xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ | __GFP_ACCOUNT);

in __address_space_init_once() and it would do what it is supposed to do.

Willy?

               Linus

