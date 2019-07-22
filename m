Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B13F6C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:31:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7333A21994
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:31:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e/C/Qyee"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7333A21994
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1868E0001; Mon, 22 Jul 2019 03:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A2AF6B0008; Mon, 22 Jul 2019 03:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED11B8E0001; Mon, 22 Jul 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEFCE6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 03:31:48 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s83so42577856iod.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=goM7DFQaf6yBihv7hYKIqrgRbj96aT6x15Ur8xgtkLU=;
        b=LokK0qJsu0dhdSfJK5DvNJliPoyuboOSfFo77Z6C4VSVtKrTRd1G4+IN5CwGGnIEeu
         rTk7BmNAUgf9KSS8Lu+CFWUKNmkBbdwzjbauSlGf0sY8g2sXfUx4412B9HGH2G0coTz8
         v+1+QCZ9SgveYxYh7iHTlktWjN2RJa6vKPzX3TBRRZVrCoEVbBIBMxFWM5bp3QjHDpUK
         KzX4w0JNtbPfju110PMhxVxgMzwtPuBmnaLS6lSCByuvYXOuVcZHTTwbCS7VfUALCk/0
         NeYYd6d+YTPRGJsJr0ZSoc+3f1ceJiN8snnBo72ilMiF5pRT4/YE6Coz/7sZRVis8gT8
         drQg==
X-Gm-Message-State: APjAAAW3xUDmQ1JUBGeVqsFqFK+mlqQBURHb5PzonddsLmW5IGO8Y83s
	XYjSju85M1mHUiFppHpcuNjpgZUJvLu+LhLbpjchlAgXi+aGyjQF2sD6KYNl/Ztny/ZNaLN3YS0
	LO9b1+FN9bpDyvZTl+Dx3yKNjh20fWyyWuJuyTFeEBSbIr00LhUtxdhRi+mYpGR5X1g==
X-Received: by 2002:a6b:7602:: with SMTP id g2mr52687563iom.82.1563780708572;
        Mon, 22 Jul 2019 00:31:48 -0700 (PDT)
X-Received: by 2002:a6b:7602:: with SMTP id g2mr52687497iom.82.1563780707765;
        Mon, 22 Jul 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563780707; cv=none;
        d=google.com; s=arc-20160816;
        b=ADXnEcG6gnZE6bc2HoW2U97yZDKrYudRKO8i8aK9IbOTXvRZs8dm96RqY6KsUUzxFh
         ZkuWgtfoq5WlFMMOWj2aQFMMxCrhLdux/SlJyW7C7L04IkvUNsGAFI4b43+YzhXHZqnC
         pzRO31D/kXnw2NsedY+TxymqQyljjTDUjkMpBegYiZavrKzQ9B3btfj3rdAqEmLDzPAT
         8sJZXd7Rd5IrNQ+gDn5gzv3oAJx4A6mbNGOysLA6dO48UmfT9mlv/5ezCy+u/KM33zpK
         sjxFpBkkiV4l+eDBfUIL5cg7tMDrbg2aMVsKhWR8e2ZUfq3FFXVEzXdKPcERtKQ+Am3R
         mxVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=goM7DFQaf6yBihv7hYKIqrgRbj96aT6x15Ur8xgtkLU=;
        b=1FY+kL5Cx+gpKiIgPDFUQWXOI7NzL9KkcH3dPUa5xjG+3FtDy4R49tJsbVd1d7O65M
         yP0TOS/PIz3cNzIV5N3QZmHhwXANwRf3CyYeD3FTzADeY1OOtz2i0xhQGjx/B18WHn0n
         KcoPx2PZzLckanXE6LvJ/975gGaDMM7i6DWUbNAM2DJg7ERDOge3LOnIk+O65X0S4LoJ
         8agYoHI7OSW4sAxfafm2oW1MtBXIke2JOMUHv9cVZRc5YInwVQJ5ztscTFWr5X3gK/mf
         a2v6Fot8Qt7uxYGAwM+sK2PksDzepq1ov74dZtIwOALrZEXNJ2kZcgfJnYGFq5ZDUbbB
         0HAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="e/C/Qyee";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h43sor94777638jaa.11.2019.07.22.00.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="e/C/Qyee";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=goM7DFQaf6yBihv7hYKIqrgRbj96aT6x15Ur8xgtkLU=;
        b=e/C/QyeeWDa6zq+nDkcLUZ5Exo4cc7mnQg9NAgvaz/ZyM1R6o28D2ZEv26f9ZTWUBL
         iHu76n6WOhKYmjVoS8rN01eVUUGVKnGiSqh2KcJ3xnQz5OSa3GafZFXARBPLK3i+3pZ7
         COdo9q+mP/JKIQDIH4hyek/cbxEeeqxhcJv8JunZgUDvI2lYHQ+qbWq37a+uoWiHxa7A
         XCm4m01SMs7QwH6zhwzjiRmKoYdAstz/4cppv/p9Uxd+BR9E3vgTfjTnVujYA5Fp7kM3
         JBG5AacCR2DOqhiBvsGz+kPkCgAL3/HO49rWOthn+2jBUJ6t5TG13JkXryYrxMeWV4KP
         Y84g==
X-Google-Smtp-Source: APXvYqzz19Lo/4a4R605hYUOywL4Adj3EdnkvL66AHSn4jeJsq/EpCbHEulJWsRKqwZcAY2Q16lQD7xW/cl7a5YfLAM=
X-Received: by 2002:a05:6638:281:: with SMTP id c1mr70371567jaq.43.1563780707278;
 Mon, 22 Jul 2019 00:31:47 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
In-Reply-To: <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Mon, 22 Jul 2019 12:31:36 +0500
Message-ID: <CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: huang ying <huang.ying.caritas@gmail.com>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019 at 06:37, huang ying <huang.ying.caritas@gmail.com> wrote:
>
> I am trying to reproduce this bug.  Can you give me some information
> about your test case?

It not easy, but I try to explain:

1. I have the system with 32Gb RAM, 64GB swap and after boot, I always
launch follow applications:
    a. Google Chrome dev channel
        Note: here you should have 3 windows full of tabs on my
monitor 118 tabs in each window.
        Don't worry modern Chrome browser is wise and load tabs only on demand.
        We will use this feature later (on the last step).
    b. Firefox Nightly ASAN this build with enabled address sanitizer.
    c. Virtual Machine Manager (virt-manager) and start a virtual
machine with Windows 10 (2048 MiB RAM allocated)
    d. Evolution
    e. Steam client
    f. Telegram client
    g. DeadBeef music player

After all launched applications 15GB RAM should be allocated.

2. This step the most difficult, because we should by using Firefox
allocated 27-28GB RAM.
    I use the infinite scroll on sites Facebook, VK, Pinterest, Tumblr
and open many tabs in Firefox as I could.
    Note: our goal is 27-28GB allocated RAM in the system.

3. When we hit our goal in the second step now go to Google Chrome and
click as fast as you can on all unloaded tabs.
    As usual, after 60 tabs this issue usually happens. 100%
reproducible for me.

Of course, I tried to simplify my workflow case by using stress-ng but
without success.

I hope it will help to make autotests.

--
Best Regards,
Mike Gavrilov.

