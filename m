Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E4A2C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 09:09:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE3820836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 09:09:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UymSpHNb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE3820836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2375C8E0003; Sat,  2 Mar 2019 04:09:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E7938E0001; Sat,  2 Mar 2019 04:09:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D6858E0003; Sat,  2 Mar 2019 04:09:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id D837D8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 04:09:36 -0500 (EST)
Received: by mail-ua1-f72.google.com with SMTP id i22so12993uak.10
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 01:09:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TdnqsYEwFkekuAoIbjErUBUwN3GEOZjaBaeYzmU0Ftk=;
        b=maHnq+wEp6Hhm54SHOUWAD/y+PX/Gi1TPUR1WRguepkLONeMYBo7M00wMuQ+Qj/W6o
         MZgV7cVuRZPTzhJKHLFydauZBmgUlr0kGtx6khUJf5lvqSLTaDBIWQVu8xfUd3DSUF5L
         pm5VXFBeBzHAjolgacqXhYKLFV7BccxStD2BgWyGfZOQ6Jx7NB1Nfx5K7NZEL8GYp88d
         hFjCFTFZ1Dqu01jmKFed4mXAzToNh3eUN2VsqDTS8LgX3WRDEUt3U2QOSmJAdY32NzmV
         FPsTM+FMcyCo9pWlTRZ4QEnWxNqyVLzOAqiS2iJ7yTK6+kcSiHiZgVwmNXRll5//SP6H
         8dAQ==
X-Gm-Message-State: APjAAAXjpqrucs6dsT8SttDN77VQz1ZqdT0t39Q5eT3UjMqlXCZEuEc3
	7OZwM7pnQVc9zUIvTdZZzFeeTPERsnB0QbQ7kS5s8XmUlECseYIqfRDLEdnVUuMHb//zWIzBGCu
	uOekZH7AeSBzI8L/WUG6aZ3X6v+syRfkwIgJj1oWvH/X0ZFXrRwZ6N3f72v53nyIOtqynWgN9Qa
	CzTajckz3PGc+AGmjhkdo2ZzFjMgMw21ekhHzmaX2r946CX5V1ULg8PcxISxolya2JZGUvRbCVZ
	5dTRU2nyj1cD/fycOO2CvP1CBY7a68yZvjmGkIe7oj/FYEZ3N9SqHFuYPKbSiJni6zYk78UXA9q
	zv4nIVyniw/V/bLOKKKIHB2RqhvOUPBgk5KlpCk3tLnmwDt9YT09CjdZt/rUG9l8v9tlj78uBwn
	n
X-Received: by 2002:a05:6102:408:: with SMTP id d8mr4957953vsq.189.1551517776523;
        Sat, 02 Mar 2019 01:09:36 -0800 (PST)
X-Received: by 2002:a05:6102:408:: with SMTP id d8mr4957924vsq.189.1551517775612;
        Sat, 02 Mar 2019 01:09:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551517775; cv=none;
        d=google.com; s=arc-20160816;
        b=jZIJ7mnJGRlAEvHkY9Xb23kj1vPDiYcRHRNvCK7bblhbpxpUG2kLN8KXJiMl4GY1/q
         P/6STzr8+ebV7UnQLxGNRgGY9eutzJMSSCuBWhncAx/YxICVh7o/VpT1X2VgZKj7NdlX
         BAxlbcdA5jKSoPXn52ln8VIl2UlEuOGwO8ifNTDeCHDJygWZc4MtCGMsloO9QO3Sczoy
         1FscWRMMkdL2ul6XQBH9y2dS0gnA8mjXC/wZmgqopy703AGZ4SAX+3srxu95rqhTfPjb
         KzfGcH+Z5EB7SAG6NaPT7+BfiBxb7Lo0dRLHm/SV8i3WYYGX4/KBXBFmoKBDJWYRwela
         B2mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TdnqsYEwFkekuAoIbjErUBUwN3GEOZjaBaeYzmU0Ftk=;
        b=KDVJ+fb/1BkFJ5v9GKqWSXwBVJ+RzeAPRJVrE41PmjUqXa1ANjWbD3T4bWMx1W0rQQ
         5pX/U0Ag8WFQtkNKuDBnHYeOnD9WX+Jf86ILHW0Gwl9I6hpnobDYOogtJXlg5rs23JxU
         sFs1dIpn4pp8kfCRYNGK2QTdhQ9wBR/Z22eB+j5rXPhzmln+wwIJSRmgN2jiLblfFmgm
         rYXkMA6qHEzrtMu0RSIe9M09C2VoCOVypKGUkCd8BMCkCcCkpZV8MTMF/e01+s3K/5AI
         e7glgPBQqJHog8UYlQ/2g//HRkFWVYhLlSYdbadKndsnWoGAU3QJMQvtIy4O4mJc+deS
         aITQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UymSpHNb;
       spf=pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oded.gabbay@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor238856vsm.92.2019.03.02.01.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 01:09:35 -0800 (PST)
Received-SPF: pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UymSpHNb;
       spf=pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oded.gabbay@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TdnqsYEwFkekuAoIbjErUBUwN3GEOZjaBaeYzmU0Ftk=;
        b=UymSpHNbGrJuu88ht9aICe2gEfCwOWaC66aoqeiDH2TNb5S56gZGDaB4Y+IEuWsp4b
         JmvRmd4SOc4QjfQiGad/XmvEVLeUebhmwuUwzX/x64UriHkF4e5u5Z+9wVQgiu11oXu3
         IINQRWLZUQvgFYvZpA8NxLJalr78wys/vQO1xj0xwqDPlKZJW0SGDKXwzy5tTfYSZSP/
         0Dzxccj+8nr0z/WLZ7BO/Q979so8BiaaHiywXlL16oRopHxKMEGy/5thAwvPckaa4a3K
         s/azx2tI04BFZiuBfU0M0hd/kavLhwUR1+Kec5ToY5cxVgu3MbxmwdJLQE3IB85ukNAW
         zvJg==
X-Google-Smtp-Source: APXvYqzMMptaRGIYU9ZdfjNXTWCjyxlc79Ck5jh7HvXYXiVAazOLibAn/X7JlLUnHboGTP9th2UyBFgah/hkFpFxK2U=
X-Received: by 2002:a67:6849:: with SMTP id d70mr4937990vsc.61.1551517775106;
 Sat, 02 Mar 2019 01:09:35 -0800 (PST)
MIME-Version: 1.0
References: <201903020948.mXKq6Z2s%fengguang.wu@intel.com>
In-Reply-To: <201903020948.mXKq6Z2s%fengguang.wu@intel.com>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Sat, 2 Mar 2019 11:09:09 +0200
Message-ID: <CAFCwf10c_rjZTDmDnDhH4wjihV8PhO=PSN2mwCwU6cB7+fx-5Q@mail.gmail.com>
Subject: Re: [rgushchin:release_percpu 321/401] ERROR: "dma_fence_release"
 [drivers/misc/habanalabs/habanalabs.ko] undefined!
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 2, 2019 at 3:42 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Andrew,
>
> First bad commit (maybe != root cause):
>
> tree:   https://github.com/rgushchin/linux.git release_percpu
> head:   8b287c57af99a4642cdf70b3b1a5ab1d90877bba
> commit: 773ae09cc9c61b8f7dc983e9a1d4ce5abbd6339d [321/401] linux-next-rejects
> config: x86_64-randconfig-m3-02280836 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-5) 7.4.0
> reproduce:
>         git checkout 773ae09cc9c61b8f7dc983e9a1d4ce5abbd6339d
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
> >> ERROR: "dma_fence_release" [drivers/misc/habanalabs/habanalabs.ko] undefined!
> >> ERROR: "dma_fence_init" [drivers/misc/habanalabs/habanalabs.ko] undefined!
> >> ERROR: "dma_fence_signal" [drivers/misc/habanalabs/habanalabs.ko] undefined!
> >> ERROR: "dma_fence_default_wait" [drivers/misc/habanalabs/habanalabs.ko] undefined!
> >> ERROR: "dma_fence_wait_timeout" [drivers/misc/habanalabs/habanalabs.ko] undefined!
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Hi Roman and Andrew.
That error comes from the original patch-set of the driver, where a
there was missing "select DMA_SHARED_BUFFER" in Kconfig. So for
certain configurations, the build would fail.
This is already fixed in the current char-misc-next tree of gkh.

Thanks,
Oded

