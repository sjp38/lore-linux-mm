Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6337EC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 22:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD3682083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 22:59:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="iGGgV2oD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD3682083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AEAB6B0007; Wed, 10 Apr 2019 18:59:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3621D6B0008; Wed, 10 Apr 2019 18:59:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24EAF6B000A; Wed, 10 Apr 2019 18:59:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1F946B0007
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:59:45 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v4so1699701vka.10
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:59:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2e+6tfpDUgb6Pn8pQ3Vvvu8T/diMiR5WDfaNtFKT3vA=;
        b=UQaKUPgm4lUCJAXGRmoR/uvIe/Wd5q4+ZfX9JfXdhkcnsOctEnvNC4x239gbdTWH2V
         JcN9beBb4eJQE1wRQIOv1tUSDjRLQZisZIcQ78FB2sndgUNCQ3LG/VKiQ/z4M8Mr5rxy
         MZ/v83lgb1hU1mtgi8b8hWluPUpHk8Mkkhh9HHGSUcth/2IW9rHHQyQtIbrBx6Zdoj8l
         UKo4HCZXngNB18+maqtjpxbYWQX9eUSA+oAbaWUsVOolHCrXjvr+TmvI9tEbdDA3W68T
         TbW6XY1qfsIfQLv/o6YLhEWtRWif64txCcJztnCY5RJuFUK8vApvTlxg51vG8BNutwAV
         xtwQ==
X-Gm-Message-State: APjAAAV1Hm/OvC+JO+AXt6jPH+cJp8osb61dL4i9T9FjQZenPEmqG7vH
	rzjpxRPQFy+L/Y3EcZbfIE3n96H8Z+Z0eaJ1nlouybi7fIru7LaQAVRMrkv/ab0JT1Kz0H0boId
	djB9zWzhltTa6zyftBSUO4zmz8eRiVUurQhE4DDy+t6a2sxznsuU6VXbSLn0U10GBFw==
X-Received: by 2002:a67:74cd:: with SMTP id p196mr26667932vsc.215.1554937185578;
        Wed, 10 Apr 2019 15:59:45 -0700 (PDT)
X-Received: by 2002:a67:74cd:: with SMTP id p196mr26667899vsc.215.1554937184805;
        Wed, 10 Apr 2019 15:59:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554937184; cv=none;
        d=google.com; s=arc-20160816;
        b=hGapu38ls9IwKoA8r4yNbEekLnz1Y27/SR5sYE7WZtnCBgsRh3aYjhxlha3mxRvQfC
         JHDMlDYNO1wUtU0vFXgT0eEv92MeAWI5rw/V2W7nBD5qfkb8D6+jX4A+NB+W19NLTLrc
         o+sduKr0KcGjYPdSHwz9DoL4vaCQlaacnro8o+UBEW3eAse36ztX0TL9riC6vXqGHaxc
         PQgqQFscak6oaRkQYB/zH2ZP1XFpzJgN151/cQ2cWR6G3rHtN0jgLB0qwuuqMsshN7IY
         HSVzPfSzR5Uet1vkqI57VXseVH52J0L95EAN2jXZCQsm6cTZiMHc/lMDBnjTkJjyPIxk
         gr9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2e+6tfpDUgb6Pn8pQ3Vvvu8T/diMiR5WDfaNtFKT3vA=;
        b=Q2yKRwqcIL6YCfs5ZyZDRtfe0eLuP2f25RFzLsKSNab8f9I3cfpAQ6MgX7jdurT2up
         ShBlB6PPyGGeccfDiubcEL6C0H9ebRGRbGAF6qA9V913qEzBKbJjd/EHOg8ogIRMVPP3
         ylXLCHStxVRiE3l0eU4OF/7Y7P5waDwflnzMZAo7p9KggFdk02zyfalzAgme7tsSeUt6
         RX6aSdVIt+r7oICymPPu3FCw9tv4reBWaY6gWIkM+GawlN3+7u6N7XIksuv5CUVGUGI1
         Ur3hwxyn5kiSQK1RB3DU//kaMNjOJEUJsIwDbufEtUL/4ICgIr/ho+Roqp8vv48mt+hq
         n6Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=iGGgV2oD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k73sor16521197vka.29.2019.04.10.15.59.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 15:59:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=iGGgV2oD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2e+6tfpDUgb6Pn8pQ3Vvvu8T/diMiR5WDfaNtFKT3vA=;
        b=iGGgV2oDfv8b1CzIHLz/qTOeEFVFEwomObQSKcz06ujaYxbN0Quln9HlMfPIZC48BI
         lJ8BIGb4KPFQYPIcxCGiJ+PvTR/Kek1lbFDlQW9PEbFhfSqKmCnbkU4fvac40zC86LOj
         9dq0ktjy50QUBGkN71t60JxG6xsG10s8DvPoM=
X-Google-Smtp-Source: APXvYqzawY46vTUn3muYQxDzQdkUMK1ygPgFBw6cXopnqlYKm171ntBEFsBHbYPo+8pYuVQrX+msHg==
X-Received: by 2002:a1f:3644:: with SMTP id d65mr23325851vka.34.1554937184067;
        Wed, 10 Apr 2019 15:59:44 -0700 (PDT)
Received: from mail-ua1-f42.google.com (mail-ua1-f42.google.com. [209.85.222.42])
        by smtp.gmail.com with ESMTPSA id u6sm2364727vsu.12.2019.04.10.15.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 15:59:43 -0700 (PDT)
Received: by mail-ua1-f42.google.com with SMTP id g8so1388254uaj.0
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:59:43 -0700 (PDT)
X-Received: by 2002:ab0:2f8:: with SMTP id 111mr24853406uah.123.1554936736434;
 Wed, 10 Apr 2019 15:52:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
In-Reply-To: <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 Apr 2019 15:52:04 -0700
X-Gmail-Original-Message-ID: <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
Message-ID: <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Dan Williams <dan.j.williams@intel.com>
Cc: Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, 
	Adrian Reber <adrian@lisas.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Richard Guy Briggs <rgb@redhat.com>, 
	"Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Thu, Mar 7, 2019 at 1:17 AM Guillaume Tucker
> <guillaume.tucker@collabora.com> wrote:
> >
> > On 06/03/2019 14:05, Mike Rapoport wrote:
> > > On Wed, Mar 06, 2019 at 10:14:47AM +0000, Guillaume Tucker wrote:
> > >> On 01/03/2019 23:23, Dan Williams wrote:
> > >>> On Fri, Mar 1, 2019 at 1:05 PM Guillaume Tucker
> > >>> <guillaume.tucker@collabora.com> wrote:
> > >>>
> > >>> Is there an early-printk facility that can be turned on to see how far
> > >>> we get in the boot?
> > >>
> > >> Yes, I've done that now by enabling CONFIG_DEBUG_AM33XXUART1 and
> > >> earlyprintk in the command line.  Here's the result, with the
> > >> commit cherry picked on top of next-20190304:
> > >>
> > >>   https://lava.collabora.co.uk/scheduler/job/1526326
> > >>
> > >> [    1.379522] ti-sysc 4804a000.target-module: sysc_flags 00000222 != 00000022
> > >> [    1.396718] Unable to handle kernel paging request at virtual address 77bb4003
> > >> [    1.404203] pgd = (ptrval)
> > >> [    1.406971] [77bb4003] *pgd=00000000
> > >> [    1.410650] Internal error: Oops: 5 [#1] ARM
> > >> [...]
> > >> [    1.672310] [<c07051a0>] (clk_hw_create_clk.part.21) from [<c06fea34>] (devm_clk_get+0x4c/0x80)
> > >> [    1.681232] [<c06fea34>] (devm_clk_get) from [<c064253c>] (sysc_probe+0x28c/0xde4)
> > >>
> > >> It's always failing at that point in the code.  Also when
> > >> enabling "debug" on the kernel command line, the issue goes
> > >> away (exact same binaries etc..):
> > >>
> > >>   https://lava.collabora.co.uk/scheduler/job/1526327
> > >>
> > >> For the record, here's the branch I've been using:
> > >>
> > >>   https://gitlab.collabora.com/gtucker/linux/tree/beaglebone-black-next-20190304-debug
> > >>
> > >> The board otherwise boots fine with next-20190304 (SMP=n), and
> > >> also with the patch applied but the shuffle configs set to n.
> > >>
> > >>> Were there any boot *successes* on ARM with shuffling enabled? I.e.
> > >>> clues about what's different about the specific memory setup for
> > >>> beagle-bone-black.
> > >>
> > >> Looking at the KernelCI results from next-20190215, it looks like
> > >> only the BeagleBone Black with SMP=n failed to boot:
> > >>
> > >>   https://kernelci.org/boot/all/job/next/branch/master/kernel/next-20190215/
> > >>
> > >> Of course that's not all the ARM boards that exist out there, but
> > >> it's a fairly large coverage already.
> > >>
> > >> As the kernel panic always seems to originate in ti-sysc.c,
> > >> there's a chance it's only visible on that platform...  I'm doing
> > >> a KernelCI run now with my test branch to double check that,
> > >> it'll take a few hours so I'll send an update later if I get
> > >> anything useful out of it.
> >
> > Here's the result, there were a couple of failures but some were
> > due to infrastructure errors (nyan-big) and I'm not sure about
> > what was the problem with the meson boards:
> >
> >   https://staging.kernelci.org/boot/all/job/gtucker/branch/kernelci-local/kernel/next-20190304-1-g4f0b547b03da/
> >
> > So there's no clear indicator that the shuffle config is causing
> > any issue on any other platform than the BeagleBone Black.
> >
> > >> In the meantime, I'm happy to try out other things with more
> > >> debug configs turned on or any potential fixes someone might
> > >> have.
> > >
> > > ARM is the only arch that sets ARCH_HAS_HOLES_MEMORYMODEL to 'y'. Maybe the
> > > failure has something to do with it...
> > >
> > > Guillaume, can you try this patch:
>
> Mike, I appreciate the help!
>
> >
> > Sure, it doesn't seem to be fixing the problem though:
> >
> >   https://lava.collabora.co.uk/scheduler/job/1527471
> >
> > I've added the patch to the same branch based on next-20190304.
> >
> > I guess this needs to be debugged a little further to see what
> > the panic really is about.  I'll see if I can spend a bit more
> > time on it this week, unless there's any BeagleBone expert
> > available to help or if someone has another fix to try out.
>
> Thanks for the help Guillaume!
>
> I went ahead and acquired one of these boards to see if I can can
> debug this locally.

Hi! Any progress on this? Might it be possible to unblock this series
for v5.2 by adding a temporary "not on ARM" flag?

Thanks!

-- 
Kees Cook

