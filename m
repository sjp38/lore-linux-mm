Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B891C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2934620850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:08:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PN3lgWkD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2934620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46B36B0269; Thu, 11 Apr 2019 16:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACCEC6B026A; Thu, 11 Apr 2019 16:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 995336B026B; Thu, 11 Apr 2019 16:08:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71B366B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:08:28 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id n18so5189059yba.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MCmOdUk7t0kgqaj6nH2xU4Mztx+DrWgSylXE7z1aynQ=;
        b=Mse4UkJO0+wGwRc7xQmbwzTeQMsBZavsWDbln842n4ZYQlQDGnT6LP/UPQ11nmpJ6p
         N/4UPcZifd8CS+1pgjOh2EFtwEJk/s8d81N7zbusUR0iuw+XmI9lk0wL1je9c2Qw2QNn
         16pmsFzqdlmhl3S370dUCakZCmKoBPtpxMZiB/Df6KkspGG4UkFqW+3CVAYPk+IiEBia
         RI1GjPWoPycn5FjWNGxURV3HDDv6wq5KeB9+4xpqMhdjijtYc08gEL9K9cs9FEqJjuov
         mLl6DavoeCtkNa7LjoWNXw1XKP8M0waL/BIRyF+w/+JIaEvzXddOBl3DxfnBKed5MtSt
         Y1Kw==
X-Gm-Message-State: APjAAAVWggRarQEouoDMpn0eAKi2n8azzX8Tv8UAzR/DM3eZBP5oBBJG
	8CXEn4I/U5hKpld/mxDVGpATi2Fr35rl+fwtenoSb2q9/LyEurnaNRkHtaF9DOk312wiUWlvoZv
	hRHmGNM9YLUdFt3B/SZJtF2Pf0mHLtHGYDnLG/L8YhjAGVu3rHdBXv4dWOie2nVqE9g==
X-Received: by 2002:a81:3010:: with SMTP id w16mr41520352yww.388.1555013308088;
        Thu, 11 Apr 2019 13:08:28 -0700 (PDT)
X-Received: by 2002:a81:3010:: with SMTP id w16mr41520270yww.388.1555013307175;
        Thu, 11 Apr 2019 13:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555013307; cv=none;
        d=google.com; s=arc-20160816;
        b=zlriWJyztW9xYpMoWQfxYbTU5zLG7Fyksi/0vBZrr/0Nvk7C9WQAXwLxGA6xORrADW
         NPw1JlqHvSWWZkJT/5peFGCHaTTTn9JW7GE1atyHg7K1QNPN1kd5g2FJOjG0DvDVHqBb
         6J/B3hdO10RgzMm158RouK8rxw/SkhtDxoeNqz6RMLiGYyXbOZ18fTCN6UFlRZn874w0
         NCp9iM6dZE4BdQqMnJOCHdcw2jm0bhNAG7TRs7ddCS0WE8uroWi+8tjzmFulmgsZQxID
         mYHeiUTfEhtd94Z5/cRx+SbDCzuqjDtK7BJZDaYIcsesteGE3oKapnwhGgzNJ84eytjT
         RBrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MCmOdUk7t0kgqaj6nH2xU4Mztx+DrWgSylXE7z1aynQ=;
        b=rfoHCudq11iOWdfJrIDUCW7o7Dc3Nspij3U5ZvOniz7S7wG09GAjgiyHU759S2zozJ
         eSHVoxbN9hmsn3ukq4dggGeEZdLdb8gje1Jury6ZvR6hu9M6HedqaHmiX3SJ8VEg5ljh
         7QS2R06ouHc5uPAcYer9fVS6XIYWmwOMbPtuKBqsyLzp9Mo1P9XFWgGgePqbqjIHq55Y
         mPmplimAgPBerBXLe0HVSnHL+eDO8H67hj537FMrqVb3EPVy8b2Nq/cxGH8zbNFbtb2l
         hGsRcbQ98Gv8F9UNwyUaFE7DlmTlMbALzHq7BY35FRSZlSxvHsGgLZTMjKNaSHDfdkqL
         kZJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PN3lgWkD;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v63sor18564313ybv.116.2019.04.11.13.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 13:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PN3lgWkD;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MCmOdUk7t0kgqaj6nH2xU4Mztx+DrWgSylXE7z1aynQ=;
        b=PN3lgWkD6qaMLyp0PtnfLsvj3OF9tRn1eTJw6d1rnTkHXEp3U1VUdI46GFU7mLRmDh
         VM95TvnWkFkCWCLBYQj7FW/P9VueQ3pYX5+lDtD9n7OUTNCa0+yld4rr+v2NdGtvDE3S
         RJEm6gVzuAuK5+ZuZKKsqopkam1J/xVP3Ndk27FoxJm3Df6UXL7Zkec3x2dCmXBKgGMC
         0rUFxlJw8ZVuup7IlIUKLI5N1XqoSO6b5Xppyw7FH0sPKTepeOuEcBBKo/259gxC1MhA
         pGgaj3+pGDxttnjAdYP+r1b3svGoEMZtD8esrn+e6PGCOEzI5HG7sJt88fYT5O1zVpRm
         Ry/A==
X-Google-Smtp-Source: APXvYqyNu6MIoeBWsFVGLQshOwqj3Wpc8wGYqvhgR1TirvxsuzR/P9yAdh9xRg5BgsxYGE/XIc7/b70QrL2TrLM8iXM=
X-Received: by 2002:a25:a049:: with SMTP id x67mr41690409ybh.3.1555013306518;
 Thu, 11 Apr 2019 13:08:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
 <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com> <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
In-Reply-To: <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
From: Guenter Roeck <groeck@google.com>
Date: Thu, 11 Apr 2019 13:08:15 -0700
Message-ID: <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Kees Cook <keescook@chromium.org>
Cc: kernelci@groups.io, Dan Williams <dan.j.williams@intel.com>, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Adrian Reber <adrian@lisas.de>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:35 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, Apr 11, 2019 at 9:42 AM Guenter Roeck <groeck@google.com> wrote:
> >
> > On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
> > >
> > > On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > > > I went ahead and acquired one of these boards to see if I can can
> > > > debug this locally.
> > >
> > > Hi! Any progress on this? Might it be possible to unblock this series
> > > for v5.2 by adding a temporary "not on ARM" flag?
> > >
> >
> > Can someone send me a pointer to the series in question ? I would like
> > to run it through my testbed.
>
> It's already in -mm and linux-next (",mm: shuffle initial free memory
> to improve memory-side-cache utilization") but it gets enabled with
> CONFIG_SHUFFLE_PAGE_ALLOCATOR=y (which was made the default briefly in
> -mm which triggered problems on ARM as was reverted).
>

Boot tests report

Qemu test results:
    total: 345 pass: 345 fail: 0

This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
and the known crashes fixed.

$ git log --oneline next-20190410..
3367c36ce744 Set SHUFFLE_PAGE_ALLOCATOR=y for testing.
d2aee8b3cd5d Revert "crypto: scompress - Use per-CPU struct instead
multiple variables"
4bc9f5bc9a84 Fix: rhashtable: use bit_spin_locks to protect hash bucket.

Boot tests on arm are:

Building arm:versatilepb:versatile_defconfig:aeabi:pci:scsi:mem128:versatile-pb:rootfs
... running ........ passed
Building arm:versatilepb:versatile_defconfig:aeabi:pci:mem128:versatile-pb:initrd
... running ........ passed
Building arm:versatileab:versatile_defconfig:mem128:versatile-ab:initrd
... running ........ passed
Building arm:imx25-pdk:imx_v4_v5_defconfig:nonand:mem128:imx25-pdk:initrd
... running ........ passed
Building arm:kzm:imx_v6_v7_defconfig:nodrm:mem128:initrd ... running
.......... passed
Building arm:mcimx6ul-evk:imx_v6_v7_defconfig:nodrm:mem256:imx6ul-14x14-evk:initrd
... running .......... passed
Building arm:mcimx6ul-evk:imx_v6_v7_defconfig:nodrm:sd:mem256:imx6ul-14x14-evk:rootfs
... running .......... passed
Building arm:vexpress-a9:multi_v7_defconfig:nolocktests:mem128:vexpress-v2p-ca9:initrd
... running ........ passed
Building arm:vexpress-a9:multi_v7_defconfig:nolocktests:sd:mem128:vexpress-v2p-ca9:rootfs
... running ........ passed
Building arm:vexpress-a9:multi_v7_defconfig:nolocktests:virtio-blk:mem128:vexpress-v2p-ca9:rootfs
... running ........ passed
Building arm:vexpress-a15:multi_v7_defconfig:nolocktests:sd:mem128:vexpress-v2p-ca15-tc1:rootfs
... running ........ passed
Building arm:vexpress-a15-a7:multi_v7_defconfig:nolocktests:sd:mem256:vexpress-v2p-ca15_a7:rootfs
... running ........ passed
Building arm:beagle:multi_v7_defconfig:sd:mem256:omap3-beagle:rootfs
... running ............ passed
Building arm:beaglexm:multi_v7_defconfig:sd:mem512:omap3-beagle-xm:rootfs
... running ........... passed
Building arm:overo:multi_v7_defconfig:sd:mem256:omap3-overo-tobi:rootfs
... running ........... passed
Building arm:midway:multi_v7_defconfig:mem2G:ecx-2000:initrd ...
running .......... passed
Building arm:sabrelite:multi_v7_defconfig:mem256:imx6dl-sabrelite:initrd
... running ............ passed
Building arm:mcimx7d-sabre:multi_v7_defconfig:mem256:imx7d-sdb:initrd
... running .......... passed
Building arm:xilinx-zynq-a9:multi_v7_defconfig:mem128:zynq-zc702:initrd
... running ............ passed
Building arm:xilinx-zynq-a9:multi_v7_defconfig:sd:mem128:zynq-zc702:rootfs
... running ............ passed
Building arm:xilinx-zynq-a9:multi_v7_defconfig:sd:mem128:zynq-zc706:rootfs
... running ............ passed
Building arm:xilinx-zynq-a9:multi_v7_defconfig:sd:mem128:zynq-zed:rootfs
... running ........... passed
Building arm:cubieboard:multi_v7_defconfig:mem128:sun4i-a10-cubieboard:initrd
... running ........... passed
Building arm:raspi2:multi_v7_defconfig:bcm2836-rpi-2-b:initrd ...
running .......... passed
Building arm:raspi2:multi_v7_defconfig:sd:bcm2836-rpi-2-b:rootfs ...
running .......... passed
Building arm:virt:multi_v7_defconfig:virtio-blk:mem512:rootfs ...
running ......... passed
Building arm:smdkc210:exynos_defconfig:cpuidle:nocrypto:mem128:exynos4210-smdkv310:initrd
... running ......... passed
Building arm:realview-pb-a8:realview_defconfig:realview_pb:mem512:arm-realview-pba8:initrd
... running ........ passed
Building arm:realview-pbx-a9:realview_defconfig:realview_pb:arm-realview-pbx-a9:initrd
... running ........ passed
Building arm:realview-eb:realview_defconfig:realview_eb:mem512:arm-realview-eb:initrd
... running ........ passed
Building arm:realview-eb-mpcore:realview_defconfig:realview_eb:mem512:arm-realview-eb-11mp-ctrevb:initrd
... running ......... passed
Building arm:akita:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:borzoi:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:mainstone:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:spitz:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:terrier:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:tosa:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:z2:pxa_defconfig:nofdt:nodebug:notests:novirt:nousb:noscsi:initrd
... running ..... passed
Building arm:collie:collie_defconfig:aeabi:notests:initrd ... running
..... passed
Building arm:integratorcp:integrator_defconfig:mem128:integratorcp:initrd
... running ....... passed
Building arm:palmetto-bmc:aspeed_g4_defconfig:aspeed-bmc-opp-palmetto:initrd
... running ................. passed
Building arm:witherspoon-bmc:aspeed_g5_defconfig:notests:aspeed-bmc-opp-witherspoon:initrd
... running ........... passed
Building arm:ast2500-evb:aspeed_g5_defconfig:notests:aspeed-ast2500-evb:initrd
... running ................ passed
Building arm:romulus-bmc:aspeed_g5_defconfig:notests:aspeed-bmc-opp-romulus:initrd
... running ......................... passed
Building arm:mps2-an385:mps2_defconfig:mps2-an385:initrd ... running
...... passed

Guenter

