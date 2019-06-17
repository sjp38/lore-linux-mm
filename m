Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4015C31E50
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:00:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A5622080C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:00:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QfGwVzUy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A5622080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16F648E0004; Mon, 17 Jun 2019 10:00:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1475F8E0001; Mon, 17 Jun 2019 10:00:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00F0F8E0004; Mon, 17 Jun 2019 10:00:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC9B48E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:00:52 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b25so4913591otp.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:00:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=v/0AosDiq0XlRMBf8oBwjVIp/eynr9o30+abHU130tU=;
        b=U3FAKH4kc+Qirpw2fdNABP3SF0alYFApuM1uOP62L2m4BfLXrMIj2yoSI5MN/VkrfS
         n4Cg86HIbfaAw1o4p4QPdwceD9Vh2HoaoqSPFs/MRJ+Cg5ELycoPEw3RZQyzA10jRRDc
         vKeIV0NtFtvlwlbCpYWox5347iQ7eMBu0aE1l2bkKRerZ2Hzz9PPgAwKR2leo7yhua/u
         gKIEhhiy2LaGpEtgWIyY5aC4RWHEJFJzI1NB0Sp+Bl5Q4fWd6JuA1BZ6ShTsfJ5iHU8H
         TwwfgCt/ZpQ6zweSUtVkysI0/QgnV+IFXGgE7s3bjPI0f1c3U23VQU8imQgyEbJSq1ZZ
         5Uig==
X-Gm-Message-State: APjAAAUeaS2FEVm1hZufBInLlRk6yDguIaCnjnWlKfArCT52WJjlXw5K
	laF7XchdNuvwDy+4nLZbfBFSh083jqK59eHw5luZc5rI6/Nv28Fnc13rwN1NVgLY4zvBdcZCZlP
	dZGlI7o4HZj26fHNwAPAIeYjvTQA3pWxTCzMTf+q1PrSsjatvcZ9GKkDMpD8XL+N+2Q==
X-Received: by 2002:a9d:5788:: with SMTP id q8mr1576480oth.237.1560780052383;
        Mon, 17 Jun 2019 07:00:52 -0700 (PDT)
X-Received: by 2002:a9d:5788:: with SMTP id q8mr1576427oth.237.1560780051699;
        Mon, 17 Jun 2019 07:00:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560780051; cv=none;
        d=google.com; s=arc-20160816;
        b=QU2Bzu1dL5bL7/7tHSImcUGKLt+XFnl8YncxtUFwZ+kWHDPqdFdegsQUnGCTO5G72F
         C0E6N5U434ImMPkwJ1pdF9cbClkxr1Tq6P+32FGlCsiH/RukMxHAMacpySC1GhDSlLwl
         Ra6gxtOfUGaGEYvko758jqEkxY0h5ngYDqniyszO0HARoxqCn53vdPxqE6NAEyf6Fuqu
         lduJvNCi4nj/YhmCGh130rKLYc0vwQdYkxtqYTWYC/5axCUf7n4OOMUhxSHFaVeKH4c+
         RdV1Hq7adqolQ3ygMEZC6oJtoPFF13TR/53+FaeOUmLl9FLHEv1zbpjBTbCP27F4qJIG
         w5zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=v/0AosDiq0XlRMBf8oBwjVIp/eynr9o30+abHU130tU=;
        b=x2nCbsTDHR8qcljv+Y4shuxleqwtloQqfK7l3V2rpwjbvWNrFRdGFpTRjLMRugqL/c
         j0eKsDitURCa8n4Wbo3PTa4onzaAj7060lKiipFWaUFny8o1FE5qkirE+8yBFlhkGmbv
         VuEq7ni/5pgbSeO4BRsN4m+jSeKy2Ml4fB8OlPJO+gRpOTSjMS2Z8H+FecFWqhV3s+1c
         +P7jUulVKId/daeWUr96r0nXQ+jUkL66/K94Dyof1S4NjuMrizjvbHjlbs8daeorg/Vp
         8k1NYd5ZViX3HB38NOL8974qaEXRqbDre1lGk4ANsZxxJp9WCvz4SpnBOzbl9I0S9yBw
         XEfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QfGwVzUy;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 74sor5441127otu.163.2019.06.17.07.00.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:00:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QfGwVzUy;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=v/0AosDiq0XlRMBf8oBwjVIp/eynr9o30+abHU130tU=;
        b=QfGwVzUyw61eYELwxKAlY9/Qm6Aj9QSJ0n+dIVkf8/4yeJfiVbarVyCC4XbKUh7zyA
         TB4mJQ/4WDEFdFlP9q8qfUxerum3OAS9kJIC9HkWocd6c82xelhC5lUZ8KGeL7GIc9b2
         Vn2SIVgDQO8hQMwPHS4nOTl0lopwU7OuI/SKFbVXrGvgWTzn57ByfbFw3uFr/5eqy03z
         O/40JUT3OWHkoJhC5IIKY/lFAiriQzdivbyM4D4bt87oTbTSaLBLA/VBa+dUA9Qn7Q8O
         AgESDbDnLQa9ZvaNVt9qijL0DoPw8QB7RGDJ+rCIOi5DiwTJKQQpi0xCcP/5ARb5gi6O
         48XQ==
X-Google-Smtp-Source: APXvYqz5F9NBThJnsQ+gL+ZpGjjXfOmWdrkG2sLPN0k3OAALt6m/XyHFzA0l3LB9J01pkclLKo1k7HRwqBHaHCOQM+M=
X-Received: by 2002:a05:6830:1688:: with SMTP id k8mr9743899otr.233.1560780051018;
 Mon, 17 Jun 2019 07:00:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190613125950.197667-1-elver@google.com>
In-Reply-To: <20190613125950.197667-1-elver@google.com>
From: Marco Elver <elver@google.com>
Date: Mon, 17 Jun 2019 16:00:38 +0200
Message-ID: <CANpmjNMCmcg8GS_pkKc2gsdtd7-A2t27mOXATY9OLb1vQW5Lsg@mail.gmail.com>
Subject: Re: [PATCH v5 0/3] Bitops instrumentation for KASAN
To: Peter Zijlstra <peterz@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, "the arch/x86 maintainers" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, 
	Josh Poimboeuf <jpoimboe@redhat.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All 3 patches have now been Acked and Reviewed. Which tree should this land in?

Since this is related to KASAN, would this belong into the MM tree?

Many thanks,
-- Marco




On Thu, 13 Jun 2019 at 15:00, Marco Elver <elver@google.com> wrote:
>
> Previous version:
> http://lkml.kernel.org/r/20190613123028.179447-1-elver@google.com
>
> * Only changed lib/test_kasan in this version.
>
> Marco Elver (3):
>   lib/test_kasan: Add bitops tests
>   x86: Use static_cpu_has in uaccess region to avoid instrumentation
>   asm-generic, x86: Add bitops instrumentation for KASAN
>
>  Documentation/core-api/kernel-api.rst     |   2 +-
>  arch/x86/ia32/ia32_signal.c               |   2 +-
>  arch/x86/include/asm/bitops.h             | 189 ++++------------
>  arch/x86/kernel/signal.c                  |   2 +-
>  include/asm-generic/bitops-instrumented.h | 263 ++++++++++++++++++++++
>  lib/test_kasan.c                          |  81 ++++++-
>  6 files changed, 382 insertions(+), 157 deletions(-)
>  create mode 100644 include/asm-generic/bitops-instrumented.h
>
> --
> 2.22.0.rc2.383.gf4fbbf30c2-goog
>

