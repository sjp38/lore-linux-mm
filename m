Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60625C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:04:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2281B218CD
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:04:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="V6HCfBzc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2281B218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32208E0005; Tue, 26 Feb 2019 19:04:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBB668E0001; Tue, 26 Feb 2019 19:04:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAA568E0005; Tue, 26 Feb 2019 19:04:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 735BC8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 19:04:17 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id r22so7359962otk.1
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 16:04:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rrHG/dtKKfHhHANQkB0lUJqMlgzwZ3RCNAV+Mz5Nhuc=;
        b=WDEdvzWPPi+MB7E7FvEGDSF//Df1/G+nK9uJCKnJSwyoWykp5sL0ufu2MQDoKFXfKk
         C4kFAr1B383m/ufhDUH3AZgceUHDAu1NmbNjtqthJcEMIA5Q7v4kyfx57NI50wLKiYjo
         B93HK9niR0OUdtBkZyJ1J4SEbzFlOE3mYgPR/AejJT15DmQAwORtWx+0vxkNj/Wd+/Mc
         OrUhilVpx3NDaFprmszYIMoOv/VtECDwXu40G47/bin+kLDBhLElP3lj83V6G7sqXlqx
         rqog7trUo+XH8MaZsagyYkN0DwRuDv7QucO+Juz9H9xMuxXzszebrzaHdEAmTg5ZzyaP
         B77A==
X-Gm-Message-State: AHQUAubEAF44SrrR0YLbq3iuU/LdxGI5q/LhAxIv4GyOST/LY2BbtF7S
	aJdcRuaRSV1Mo1P8Y1DYiuMF7dHUakm3mKplXgqurwjGVU7fLBIu7n41NBXBOGAbxStq+BboUMw
	vzguv3rak1SvRy9FdJl/+brwh74zByv0fkHC6cc/ysPR9iCkuuvnHLe65X2kh9Tu5JZGhnPHi8k
	I+CJjU1XT2bQpb0rdSGb6eKSsnFHz6l+peIo0EYckt+aeapIKW9VFGOihCxq5pykbZCGAG+18PM
	t1tc+OEgCatWr2S0pOzuD+3nve7YFtwlvd9K/PcD8kcbUcrA84aTHlCHzovGFVrYX3sdm9GynvU
	MCQ7+IYQYQqsA3EPI9uXV5A9TL6HdqvFohQ+guB1TLg2lzpxlEpUCP+h691PhvLF4b+9V2uGZr9
	2
X-Received: by 2002:a9d:4b1a:: with SMTP id q26mr447056otf.10.1551225857079;
        Tue, 26 Feb 2019 16:04:17 -0800 (PST)
X-Received: by 2002:a9d:4b1a:: with SMTP id q26mr447006otf.10.1551225856068;
        Tue, 26 Feb 2019 16:04:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551225856; cv=none;
        d=google.com; s=arc-20160816;
        b=NPcAzXw3WZ+MYP0eiVn9eejDhz1pdaUq2NRDhJ9H697r0I/34JpvFCNJzOhuJwR3Am
         nXxJ49qaawXo1uUbo8vFIJtmgOD05SFxqDGUSpNbZvlaBcFphqRfV6QwCVh/ZB54kKNs
         mLP5kkIpkH1SPZxgmObt3ZmW0bl2BJKeMSMDh02nJ5D0ABKtbwY47fofTaQr3XLPo5wv
         KG4+1jKN+bjeDVEccVH4dbmaQI++2UImwEdeqWCxeJpVgP/BJtT3TX6acjT8LI+ZWJNu
         5WIZ+TeaVsaJ7bue7WS7vzepTjwjqNo7xnSHFvLIfjgYNeAx9OE0xurRBAoWnoN3MHtV
         4bcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rrHG/dtKKfHhHANQkB0lUJqMlgzwZ3RCNAV+Mz5Nhuc=;
        b=jAQVsNVr2FJfOaES5ucGR7+MOVdM+JVyuG3Up9bZTHN6nz1g4HYtfzl63lXz9eXkr9
         tbfdjCV7SLOm4eSHYAvob5foGzkGEyj9uPeEPS7/3nu66Gp3sfg/NKICQqWge7b+nUmI
         hOr3Ig86sH2FQy8uohtz+IAwm82je9h9N30P1JuSDZtU3D0JiVb/RCLMnUS1py2BLQP8
         d7Z5ut6W/jt1tPEROU62U4LHQFDcKNQ+Ig4mmxl101dxdHyv8c87tSrB1GbWkPPzmfOS
         jeH6Wl5ITNN1qzKuNXke33nEHWXhnRiGOpS/UmVPneR/2AOjjLLvwGHWSPOylxD0qsmt
         O5Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=V6HCfBzc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14sor7259021otp.156.2019.02.26.16.04.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 16:04:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=V6HCfBzc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rrHG/dtKKfHhHANQkB0lUJqMlgzwZ3RCNAV+Mz5Nhuc=;
        b=V6HCfBzcfnjFssuqjQd4kVxAcRjDPvv7SHIe3YOKqnCd54FHnA+5KQHjz2Iq4azb8+
         AkKXv5FKTQRbh5SWelNr0hm7EYBrrZ626EF49pwbudD7edY98s4jviyIJEEN8TmiDgVF
         3UL9iMr+hU/W5vso6a/1bdUFmBN4KvdO3iAER1cqouKHMXMxrBlZyHFyyqjYSg8wTsyg
         Zw7sAgQzjTVwawEyiwKfkTmJJGXBCBe31JzEQGRgbjTCMTeCdqi89WZyF6HOx6rWyOvd
         PHQAcsGC4CtN1M1WIP8dlpOvygZOkn61cAYCFSs+cJNq+uJkbzAcvS1ywej2OYxLqblI
         hiDQ==
X-Google-Smtp-Source: AHgI3IY1svijvLkauq7rncxA+KVzUUnWRQ9yAKy7sB13oouHnj7BpiwnibvcPCFf8jD2ZE4D9qJip1sp7Gv3DX6Zs9U=
X-Received: by 2002:a9d:7a87:: with SMTP id l7mr417454otn.98.1551225855529;
 Tue, 26 Feb 2019 16:04:15 -0800 (PST)
MIME-Version: 1.0
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com> <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
In-Reply-To: <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 26 Feb 2019 16:04:04 -0800
Message-ID: <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>, "kernelci.org bot" <bot@kernelci.org>, 
	Tomeu Vizoso <tomeu.vizoso@collabora.com>, guillaume.tucker@collabora.com, 
	matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com, 
	enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, 
	Adrian Reber <adrian@lisas.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Michal Hocko <mhocko@suse.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
>
> > On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> > > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> >
> > > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > > >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> > > >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> >
> > > Thanks.
> >
> > > But what actually went wrong?  Kernel doesn't boot?
> >
> > The linked logs show the kernel dying early in boot before the console
> > comes up so yeah.  There should be kernel output at the bottom of the
> > logs.
>
> I assume Dan is distracted - I'll keep this patchset on hold until we
> can get to the bottom of this.

Michal had asked if the free space accounting fix up addressed this
boot regression? I was awaiting word on that.

I assume you're not willing to entertain a "depends
NOT_THIS_ARM_BOARD" hack in the meantime?

