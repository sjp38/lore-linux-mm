Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CAF2C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C35AD21738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:49:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JHBW4aAO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C35AD21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 481216B0003; Tue, 23 Apr 2019 14:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 431516B0005; Tue, 23 Apr 2019 14:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3205F6B0007; Tue, 23 Apr 2019 14:49:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B09A6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:49:28 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v4so7380725vka.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:49:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/T9qo9dXOGam1pOhMSAqSonYXFNAxs4dctak+jq5XkQ=;
        b=pnyI+EvaOHYsmkL7vl5bgBLJiaIg+ZrD5PhNpq9Wtr2wxNJq9Q7e4Zr8a4Jjy5v8qN
         9jqmk+4xKLciSzcLmFR8cYogGZhbPnnoFgpc/ADVh9kXJoSuVqsV34hxsRRrC0vcR8hH
         lcm4uGHvuzPo+eG0UtPi/he8sEzoYDOXo/6BsIt/7zyQvDnP7Tdd/cu0JprEHqIQCIdx
         cjnBnkERTqUDNMfzco6OJH+AVX7E8IGrzqDaqHsqeqgGOjTWctO0VVoW0sd0McbAhv6i
         2O/hqvM+rJOopyvCIaN2ILKF2rzoITur4OAM+XR8QC353yNKAjC03whE+PqFhaiItQqO
         brPg==
X-Gm-Message-State: APjAAAWKjxeU4WTUG2R8B2mVoYj/OdIj9uSOeA7Dg2SCgyn83Gn7AN36
	uOsGoShYv9w9Hbjyzsijwz6SqnFEX/TILMU0fPCX1F0cMylnnX92Vwz35QdXoHgna64cNMLFjFI
	CC3ykFgOl3B6VspcesP4YVllK1Lb1yJdp5IyvPZI/OSqXepPuU6FHsCrhAc7WmmuRZw==
X-Received: by 2002:a05:6102:191:: with SMTP id r17mr4257802vsq.0.1556045367314;
        Tue, 23 Apr 2019 11:49:27 -0700 (PDT)
X-Received: by 2002:a05:6102:191:: with SMTP id r17mr4257785vsq.0.1556045366750;
        Tue, 23 Apr 2019 11:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556045366; cv=none;
        d=google.com; s=arc-20160816;
        b=g5feL/LSSI0Cn9OVUmLSZBC5pEdplOFPsXrU9CItQ6gqFHJnL9hSqnSF9veiq98Qvk
         /6GPI7Lean8/Zn1g+mwN85ZaA7gv6J+oqJEJEy4oz1ZqJeQN4Dx3SjmTFkF5oy0cwy17
         Z/ewqlLIgRKfT8WjAoikm7No993qNzXkPgBaL5kJJ40mAFinAqb5mwT68sLAMcQWMWB+
         FVXajyCHVVKtDLnkpcv/nmGGZkzbbb0U7Q/2CIVoHaR1yVIkn6sac7IpnloN+3/e3Lpg
         kd7FSF3EXfzIwVzhpDquXZ98su1vttWztPaAs5fWBsuDZka2YnnZ/EVAl8NLclk5qyCo
         bD5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/T9qo9dXOGam1pOhMSAqSonYXFNAxs4dctak+jq5XkQ=;
        b=kLu2uL+0YWvRoCT4yC8VGk796BMT3eC57/fRG5pZpss3kpFW+Sqk1OxOm8W3ofB0jT
         y53hpxiIymJ7BOBuRs4ih4Eje0LnkbLCFvfICCNn5YBOB8NHrZH4SpmjWiP9+cnwmub+
         Vm9tQhgrONR/tblKvhZMAWesBrD6t5zke1Yp3iD4GcodJEEnBDJGxNPHlEK32cidk9aE
         vefEyNuBzoU3MTQhrMsXQu5tYegBc5xiSqd9VZdghgFOhhi/GzQndywaWmGSikWHXnAq
         kuNzlLS70KNUSP4hqq8nbxmFkpZ89fURCK8eH4b0LaFO1Vp/wbiPECWG1PK7GepADUwN
         fLfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JHBW4aAO;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f127sor750081vsd.119.2019.04.23.11.49.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 11:49:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JHBW4aAO;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/T9qo9dXOGam1pOhMSAqSonYXFNAxs4dctak+jq5XkQ=;
        b=JHBW4aAOIAjQxAPOtuiWiFgtH93O689gkxe5m6ABY0SG7DuEDYyjBjOKwdBADUDI4f
         MZbJZrn1mDNVGuM9vPk7Wqlmg7LsTZicn2PRqdF768u/nKaMExHfHw+nayNTpoEWn/jy
         GqJ4uliwl8NZJLtsd6NeZlkStKKwQDPzhqZZ0=
X-Google-Smtp-Source: APXvYqwxjAmPHnqxWbCCgheasas/BabVOCALRFAtCN6nLVo9W5qLHZJidvhs4dcxwex0VxNLZ3Luew==
X-Received: by 2002:a67:f753:: with SMTP id w19mr14808887vso.27.1556045364353;
        Tue, 23 Apr 2019 11:49:24 -0700 (PDT)
Received: from mail-vs1-f45.google.com (mail-vs1-f45.google.com. [209.85.217.45])
        by smtp.gmail.com with ESMTPSA id s194sm7015398vkf.37.2019.04.23.11.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 11:49:23 -0700 (PDT)
Received: by mail-vs1-f45.google.com with SMTP id j184so8874319vsd.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:49:22 -0700 (PDT)
X-Received: by 2002:a05:6102:417:: with SMTP id d23mr5082569vsq.48.1556045361827;
 Tue, 23 Apr 2019 11:49:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com>
In-Reply-To: <20190418154208.131118-1-glider@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Apr 2019 11:49:05 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+tJJbyoZ=nSpSeiihD=NHwFJ6G9Ku5c21G5nQfEiKPwQ@mail.gmail.com>
Message-ID: <CAGXu5j+tJJbyoZ=nSpSeiihD=NHwFJ6G9Ku5c21G5nQfEiKPwQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] RFC: add init_allocations=1 boot option
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 8:42 AM Alexander Potapenko <glider@google.com> wrote:
>
> Following the recent discussions here's another take at initializing
> pages and heap objects with zeroes. This is needed to prevent possible
> information leaks and make the control-flow bugs that depend on
> uninitialized values more deterministic.
>
> The patchset introduces a new boot option, init_allocations, which
> makes page allocator and SL[AOU]B initialize newly allocated memory.
> init_allocations=0 doesn't (hopefully) add any overhead to the
> allocation fast path (no noticeable slowdown on hackbench).

I continue to prefer to have a way to both at-allocation
initialization _and_ poison-on-free, so let's not redirect this to
doing it only at free time. We're going to need both hooks when doing
Memory Tagging, so let's just get it in place now. The security
benefits on tagging, IMO, easily justify a 1-2% performance hit. And
likely we'll see this improve with new hardware.

> With only the the first of the proposed patches the slowdown numbers are:
>  - 1.1% (stdev 0.2%) sys time slowdown building Linux kernel
>  - 3.1% (stdev 0.3%) sys time slowdown on af_inet_loopback benchmark
>  - 9.4% (stdev 0.5%) sys time slowdown on hackbench
>
> The second patch introduces a GFP flag that allows to disable
> initialization for certain allocations. The third page is an example of
> applying it to af_unix.c, which helps hackbench greatly.
>
> Slowdown numbers for the whole patchset are:
>  - 1.8% (stdev 0.8%) on kernel build
>  - 6.5% (stdev 0.2%) on af_inet_loopback

Any idea why thes two went _up_?

>  - 0.12% (stdev 0.6%) on hackbench

Well that's quite an improvement. :)

-- 
Kees Cook

