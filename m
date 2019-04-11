Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E6ABC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4155217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:42:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZHLg5oUi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4155217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 527D76B026B; Thu, 11 Apr 2019 12:42:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FC796B026C; Thu, 11 Apr 2019 12:42:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C5ED6B026D; Thu, 11 Apr 2019 12:42:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 176846B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:42:49 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y9so4803497ywc.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:42:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BSA7wAcOkSLlzctNlW4vWiUg1c9DSNGuTiqEkfsYEjo=;
        b=WmYyvBza9Yt0eH2tt6EY49sGzkhPz0jpP5Tfo/Za3z1ADx6FXlG9lwWOQcfEnHeF25
         5vxK67O1E+k7yIZqBPevAucquVWLcalNNvc4EHQMXnS/1io+jmpKFmMGYMbqm8PkNVTq
         g3kpJd8L/h/koHdN44GqtFcSJqv8e3ILivm3lcCtZRsfS5/Zm0z3A+l0HyhaQ4Dxg5gW
         jAA42dlw4vHKsk0pRpbL8tuXJO+dyeluKnTE2/pcywzW+Vtq2oIgMjoPqxE0yV5AwhaX
         vfnUppdSaVcXZw1JOItglA4c2TjbyPNEGm88Xw3vvD1pxde9pV5GbKEo2BzUABL1liOc
         TqqA==
X-Gm-Message-State: APjAAAWgBC7W9AxgwE5Lte9CezN4mv+DuehrUP7dMQKwQbgpNrxhAioG
	ElKAb4wzBzXDVhOInBqR8V6+Ui3XldZ4dQYrEDsFGyVrqaYWPn+2D/VQlK9SNC9dDFM7znRRaPm
	96HT3cU/01Gz6BU5Oo7A1Yoh82/7WyH2Kjyw58crjsamYbBf9rpUBcqvkgt24gvmEcw==
X-Received: by 2002:a25:4147:: with SMTP id o68mr43537074yba.148.1555000968793;
        Thu, 11 Apr 2019 09:42:48 -0700 (PDT)
X-Received: by 2002:a25:4147:: with SMTP id o68mr43536998yba.148.1555000967982;
        Thu, 11 Apr 2019 09:42:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555000967; cv=none;
        d=google.com; s=arc-20160816;
        b=k8Csupr+GAGKZpPEG2yYePxbIphAYBIktrYKElvnpA4qvlQ0bXPcxQTjrnIiQyXvfn
         mOxq76GSYBdp22itryErt96rcIBtfB0qE5zEj922b6J8oCMQc1jm9AoNbTiWvpf0fbu+
         OW/xkbcSjw0k+ere1gUMQ4h4jaQgNfnecVLolAzv4mY/C6uJVAzOTOSYX9IZCfQLSbQJ
         5ZaViERqnwpaKHviWr2QW2pw1LyOP6RVZmfbCgyP2mt+ag+Nbvi0LLDfcr32XZLCGo3n
         /oK5Zo3+2eVLOfL5r+0b4pAIwHWj3qxp24jvdYeZMOmbdromTQ958WaCHbShRRLwuANf
         LQ0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BSA7wAcOkSLlzctNlW4vWiUg1c9DSNGuTiqEkfsYEjo=;
        b=fV9Hn2lMVxPvr0g35qaPWItD2VRSc2Err7PKP3NLH4KRKiZ9n7jE2rOfcoKzQvovNS
         82Ga/lFJotBG7nprOE3EgUFN/RDRrqwvJTHtu1gId1oKa84HyAr9P+Vw6qoY3vMlumBx
         HwJ2kg9fFgLyVeX4isQOZTBhd+13hDUWcZFNELZYmCWftWAo9Jlnip2eSb5qcGy+5+Dl
         +Ywgy5UmUPMM6FYOQC8/K2m/Y+ZkQ0PwWexF9C9ZV7/sONtU6HhKCr0764AsWFDluMEX
         VPACEtfZQvrBho+MbqyAW5GJUq17Fememj/Dse4/dkQyLT7UZ6cIXCwQr9W1M5bVT1XS
         b3/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZHLg5oUi;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 128sor20181974ybg.153.2019.04.11.09.42.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:42:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZHLg5oUi;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BSA7wAcOkSLlzctNlW4vWiUg1c9DSNGuTiqEkfsYEjo=;
        b=ZHLg5oUiZ7PADbbxTPmb/WsaETcl7adx55BpjlMoWbMWOUMagh8EL+bnGH7n4dVIWC
         qIOFh+IZ4PXVC+gpv1xWnXCTDaIkAs/aYqw4hdqipEov8gj480QMTrffAfUdi3t/5ZCC
         ltm4BxoinZ37dYVl2S4vxNSMIyAWgMB5MiV6GWuQ+K4AZF94R5PHOm+aLCsbZJ+eYo4P
         5lvp3KA2ER4agUaLhJ2YrtqZybvuymIFVHcFYzcTJnbRDOujXyeU6e/kJjze+bmz/ZSM
         qznxmiBhseZ1op2Dc+iNdJy2sSiaVri/gJnsd431sO+SGY+XMqhvpzwECiFx72JBYAYz
         G/Wg==
X-Google-Smtp-Source: APXvYqwitDr3lcVKRDmlY1iKyvtiPzjYrs/F9J5p5FgXRkJnmEUEV+NtSF97So8fFJqc1eKEHvCRAmddioLmTd0my8c=
X-Received: by 2002:a25:e54a:: with SMTP id c71mr40728505ybh.336.1555000967421;
 Thu, 11 Apr 2019 09:42:47 -0700 (PDT)
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
In-Reply-To: <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
From: Guenter Roeck <groeck@google.com>
Date: Thu, 11 Apr 2019 09:42:35 -0700
Message-ID: <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: kernelci@groups.io, Kees Cook <keescook@chromium.org>
Cc: Dan Williams <dan.j.williams@intel.com>, 
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

On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Thu, Mar 7, 2019 at 1:17 AM Guillaume Tucker
> > <guillaume.tucker@collabora.com> wrote:
> > >
> > > On 06/03/2019 14:05, Mike Rapoport wrote:
> > > > On Wed, Mar 06, 2019 at 10:14:47AM +0000, Guillaume Tucker wrote:
> > > >> On 01/03/2019 23:23, Dan Williams wrote:
> > > >>> On Fri, Mar 1, 2019 at 1:05 PM Guillaume Tucker
> > > >>> <guillaume.tucker@collabora.com> wrote:
> > > >>>
> > > >>> Is there an early-printk facility that can be turned on to see how far
> > > >>> we get in the boot?
> > > >>
> > > >> Yes, I've done that now by enabling CONFIG_DEBUG_AM33XXUART1 and
> > > >> earlyprintk in the command line.  Here's the result, with the
> > > >> commit cherry picked on top of next-20190304:
> > > >>
> > > >>   https://lava.collabora.co.uk/scheduler/job/1526326
> > > >>
> > > >> [    1.379522] ti-sysc 4804a000.target-module: sysc_flags 00000222 != 00000022
> > > >> [    1.396718] Unable to handle kernel paging request at virtual address 77bb4003
> > > >> [    1.404203] pgd = (ptrval)
> > > >> [    1.406971] [77bb4003] *pgd=00000000
> > > >> [    1.410650] Internal error: Oops: 5 [#1] ARM
> > > >> [...]
> > > >> [    1.672310] [<c07051a0>] (clk_hw_create_clk.part.21) from [<c06fea34>] (devm_clk_get+0x4c/0x80)
> > > >> [    1.681232] [<c06fea34>] (devm_clk_get) from [<c064253c>] (sysc_probe+0x28c/0xde4)
> > > >>
> > > >> It's always failing at that point in the code.  Also when
> > > >> enabling "debug" on the kernel command line, the issue goes
> > > >> away (exact same binaries etc..):
> > > >>
> > > >>   https://lava.collabora.co.uk/scheduler/job/1526327
> > > >>
> > > >> For the record, here's the branch I've been using:
> > > >>
> > > >>   https://gitlab.collabora.com/gtucker/linux/tree/beaglebone-black-next-20190304-debug
> > > >>
> > > >> The board otherwise boots fine with next-20190304 (SMP=n), and
> > > >> also with the patch applied but the shuffle configs set to n.
> > > >>
> > > >>> Were there any boot *successes* on ARM with shuffling enabled? I.e.
> > > >>> clues about what's different about the specific memory setup for
> > > >>> beagle-bone-black.
> > > >>
> > > >> Looking at the KernelCI results from next-20190215, it looks like
> > > >> only the BeagleBone Black with SMP=n failed to boot:
> > > >>
> > > >>   https://kernelci.org/boot/all/job/next/branch/master/kernel/next-20190215/
> > > >>
> > > >> Of course that's not all the ARM boards that exist out there, but
> > > >> it's a fairly large coverage already.
> > > >>
> > > >> As the kernel panic always seems to originate in ti-sysc.c,
> > > >> there's a chance it's only visible on that platform...  I'm doing
> > > >> a KernelCI run now with my test branch to double check that,
> > > >> it'll take a few hours so I'll send an update later if I get
> > > >> anything useful out of it.
> > >
> > > Here's the result, there were a couple of failures but some were
> > > due to infrastructure errors (nyan-big) and I'm not sure about
> > > what was the problem with the meson boards:
> > >
> > >   https://staging.kernelci.org/boot/all/job/gtucker/branch/kernelci-local/kernel/next-20190304-1-g4f0b547b03da/
> > >
> > > So there's no clear indicator that the shuffle config is causing
> > > any issue on any other platform than the BeagleBone Black.
> > >
> > > >> In the meantime, I'm happy to try out other things with more
> > > >> debug configs turned on or any potential fixes someone might
> > > >> have.
> > > >
> > > > ARM is the only arch that sets ARCH_HAS_HOLES_MEMORYMODEL to 'y'. Maybe the
> > > > failure has something to do with it...
> > > >
> > > > Guillaume, can you try this patch:
> >
> > Mike, I appreciate the help!
> >
> > >
> > > Sure, it doesn't seem to be fixing the problem though:
> > >
> > >   https://lava.collabora.co.uk/scheduler/job/1527471
> > >
> > > I've added the patch to the same branch based on next-20190304.
> > >
> > > I guess this needs to be debugged a little further to see what
> > > the panic really is about.  I'll see if I can spend a bit more
> > > time on it this week, unless there's any BeagleBone expert
> > > available to help or if someone has another fix to try out.
> >
> > Thanks for the help Guillaume!
> >
> > I went ahead and acquired one of these boards to see if I can can
> > debug this locally.
>
> Hi! Any progress on this? Might it be possible to unblock this series
> for v5.2 by adding a temporary "not on ARM" flag?
>

Can someone send me a pointer to the series in question ? I would like
to run it through my testbed.

Thanks,
Guenter

> Thanks!
>
> --
> Kees Cook
>
> -=-=-=-=-=-=-=-=-=-=-=-
> Groups.io Links: You receive all messages sent to this group.
>
> View/Reply Online (#350): https://groups.io/g/kernelci/message/350
> Mute This Topic: https://groups.io/mt/30172851/955378
> Group Owner: kernelci+owner@groups.io
> Unsubscribe: https://groups.io/g/kernelci/unsub  [groeck@google.com]
> -=-=-=-=-=-=-=-=-=-=-=-
>

