Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA119C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:15:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF091214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:15:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kn07xZZN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF091214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46AE16B0006; Mon, 16 Sep 2019 11:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F4586B026B; Mon, 16 Sep 2019 11:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC3B6B026C; Mon, 16 Sep 2019 11:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id 03A7B6B0006
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:15:38 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6E3B6181AC9B6
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:15:38 +0000 (UTC)
X-FDA: 75941133156.20.cloud96_887618121de5c
X-HE-Tag: cloud96_887618121de5c
X-Filterd-Recvd-Size: 4077
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:15:37 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id a127so78878oii.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:15:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=myU5/TC8EM0o03fkgYztHIvhCCZ3n2MmrOaOleMEGcA=;
        b=Kn07xZZNH8LhKSWctdaltI81HMhS1HytLccqyQ3Yaw7hN3M01YoZBZrXG8xAjz2nX4
         2MY4xfjSVwq9U2LKNZqm96npY8ZQaSTj6vQOFlVwzxv2QuMtxe4x8HWU0qoXzfRgKvIp
         trRh8UrXdren7ITIZWvRLdhZZMnwmCR2PV/bpuX5tvYKTT+32gfXtl3MYM9OcrHliWKQ
         kcg5D1EEcLxLuSjLq0XFepTA0qWt5YsWTrghI771EWdJPPiRKOaR2pFxMSgjAXQJ19GN
         Xz1byM+4awfK2AdRk1ah6M8xE+KanR7caW8wYgn8mfSw35EZaiLm2lq0SCKXmglCHK/B
         wkEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=myU5/TC8EM0o03fkgYztHIvhCCZ3n2MmrOaOleMEGcA=;
        b=ZrGqBIykQ0FgZPAGU/GiHZripp6El5pyES1vXUxQFr6R5q9nTpKbPAw0AOfDtMbyjN
         YMtgC8TUBK1bl5yDo8bnCxN73DTH2tVZAoKExydiAA/mQJ2QhfbUxUbJz9TNac6MRDrM
         r3ckwaEa6+4gb1+u/N6nlDZNoGjrBbIV7Qy7ijKjiJFDJV99JOT+QR2tRoRVI9GiVwia
         u2oYaJOXOt2xzdLmQCIzW+m1e2akUVQLGzFMhX2SF3edhYrC94ALtDC22YeYuHKGQJ/c
         NSMktrf4bQvfopSEWZbaYNTYziX8Tdez8IZldFysgZ32Ds+RK53YitypNTAUePFjEJZl
         dpMg==
X-Gm-Message-State: APjAAAVu6ZDECrT1uiroBljQWMwaQIP7/cj/jIG7ptgN4v0Zu855WOmN
	O4H/KEtsmb0HiaxFIIeReugY1vp6+nzfTHRyX1o=
X-Google-Smtp-Source: APXvYqxv0WB7yHn0EYqv/F75KfuLWbRubTIglyprLwvBnqwa7v1kd9h+n3uI3ynbbt0c4wWZPM3b0EN4o6BFmNCQzMg=
X-Received: by 2002:aca:4f8f:: with SMTP id d137mr61864oib.33.1568646936752;
 Mon, 16 Sep 2019 08:15:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190915170809.10702-6-lpf.vector@gmail.com> <201909161257.ykb3lopd%lkp@intel.com>
In-Reply-To: <201909161257.ykb3lopd%lkp@intel.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Mon, 16 Sep 2019 23:15:25 +0800
Message-ID: <CAD7_sbG1_E1ZTRWHb21GaYcjRsr9e6CPSxXRauTOc4sLpCTeDA@mail.gmail.com>
Subject: Re: [RESEND v4 5/7] mm, slab_common: Make kmalloc_caches[] start at
 size KMALLOC_MIN_SIZE
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 12:54 PM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Pengfei,
>
> Thank you for the patch! Perhaps something to improve:
>
> [auto build test WARNING on linus/master]
> [cannot apply to v5.3 next-20190915]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Pengfei-Li/mm-slab-Make-kmalloc_info-contain-all-types-of-names/20190916-065820
> reproduce:
>         # apt-get install sparse
>         # sparse version: v0.6.1-rc1-7-g2b96cd8-dirty
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
>
> sparse warnings: (new ones prefixed by >>)
>
> >> mm/slab_common.c:1121:34: sparse: sparse: symbol 'all_kmalloc_info' was not declared. Should it be static?

Thanks. I will fix it in v5.

>
> Please review and possibly fold the followup patch.
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

