Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD236C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:35:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F5942081C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:35:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F5942081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F24AF6B0005; Wed, 22 May 2019 12:35:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5116B0006; Wed, 22 May 2019 12:35:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D76436B0007; Wed, 22 May 2019 12:35:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 896396B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 12:35:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so4431535eda.11
        for <linux-mm@kvack.org>; Wed, 22 May 2019 09:35:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zj+UJDFqb5lMoiSFTFapDkV0CuL9IYOnWsyuJ96DKE0=;
        b=TjPYm2FJBI/GhWHTz4/wy6p2kIEzectT/reJo7fon9TqCxXC4UdBE0MicxzPpLOzZG
         SEAdJNHx63rxbUknad1jRKUSOBLkTGFpKjL7wcbMoaB4PXYIJ9MzV5LwuOzGof8YqasA
         Scpk8vzGL9v2dmskwAt305rzHsD6O9K7JeNWStyXWqYxHXZ0MOE5jwQb9TvshGehMdx9
         NCEMwjUGOeL1fkK0OEY34ccYqSCjibVLsgrDUxeE7sxXKpmUwCEOTJpioHosT9pRSZ2a
         AoM5ucxY9Jd6B0E+y2mce7fu2dV5g8qBMiyGP4tyRdpLHVik2Mb++4RF+bdC6ASeE+hg
         1sTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVSWgn0FVlAzhr64m99HJa+yVXOZHjq+KBAgEs/fhOk9+NwEBnn
	nHDXEMbyIHoONRm3NYhnOAT6rBWWzUANiezupwxThGWGpgtilUI8u7Weel9qdbEx5HZ5bqAq56/
	LK1NXzjms93S04LddX9ZIi9caQXQlyo7QxAV8JypOp+9Is34nOpmfdevKkUBJk9TQ4w==
X-Received: by 2002:a50:9765:: with SMTP id d34mr91820363edb.195.1558542939106;
        Wed, 22 May 2019 09:35:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybPiLstCoop9zL1yjBTUwTmsn5fiqJX+9Uhha9dQ72EFEg47O7Kc8ZKZdBIpoyRsBx02Go
X-Received: by 2002:a50:9765:: with SMTP id d34mr91820186edb.195.1558542937636;
        Wed, 22 May 2019 09:35:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558542937; cv=none;
        d=google.com; s=arc-20160816;
        b=yyFlD+Rw06KOBqfsUbuAvolVKxm/5Zo15Ndbep2pelwCEc0s5MFO2Ul0F7bYaI0L1/
         YOMhWa3iuCjTmimt5/M7HRtkVvWVRqJ7vHXi9BCbw25cUpwk7asXwslnGi68sZZhtAuw
         w7h4u1EauZVuUX2rPGkm2UTLMXVTfhL05KA14GEh64GEvVMPnMHdCQkdppXl2K4zL/1e
         mEsg33ldEsxLZaZy09JuT79aKFTsm3n/KT5zPC3bZztdPDsmpCMJUpHEQgEmMk+Tjd21
         KoX9ACadvPs551WD9y8MvnacPo2Qtx0tuenxR0D091RCTpqngzYUv4BkmflSfL5Ew/ui
         wZyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zj+UJDFqb5lMoiSFTFapDkV0CuL9IYOnWsyuJ96DKE0=;
        b=a6igr94Yt3fplGcRjG7fGN77fzF4UDeaf+rsaxJFFEuIbx0Ve2tKIpv34NbEB1ySuP
         FJ49v8rX7CUvVl72jmA20G32Fc+vifWGEdkhJfyN6oYpBCMdi7Sikljg0WwFy40U46dX
         kvKJ2owU4NAfHPPmeTcX/TMQ3xq2ikINvoXEd+GIrdO1QSUqKhWWJuNV16+G4MGwaUYr
         bk7A057kox5EZr7btHPV1tYBXMmqPmlDPeLIAW0J/R50YcgB2RzZqIxm4Ps2kw145lkC
         IN5JRLkiJOM8IoXyx8WRACa+YNUlDxa08iL3n9kd0rcQCVSBqdLWGQqAe4rb5ITCEgXs
         mZdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t46si1705963edd.224.2019.05.22.09.35.37
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 09:35:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 39D60341;
	Wed, 22 May 2019 09:35:36 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1CE693F5AF;
	Wed, 22 May 2019 09:35:29 -0700 (PDT)
Date: Wed, 22 May 2019 17:35:27 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: enh <enh@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190522163527.rnnc6t4tll7tk5zw@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 08:30:21AM -0700, enh wrote:
> On Wed, May 22, 2019 at 3:11 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Tue, May 21, 2019 at 05:04:39PM -0700, Kees Cook wrote:
> > > I just want to make sure I fully understand your concern about this
> > > being an ABI break, and I work best with examples. The closest situation
> > > I can see would be:
> > >
> > > - some program has no idea about MTE
> >
> > Apart from some libraries like libc (and maybe those that handle
> > specific device ioctls), I think most programs should have no idea about
> > MTE. I wouldn't expect programmers to have to change their app just
> > because we have a new feature that colours heap allocations.
> 
> obviously i'm biased as a libc maintainer, but...
> 
> i don't think it helps to move this to libc --- now you just have an
> extra dependency where to have a guaranteed working system you need to
> update your kernel and libc together. (or at least update your libc to
> understand new ioctls etc _before_ you can update your kernel.)

That's not what I meant (or I misunderstood you). If we have a relaxed
ABI in the kernel and a libc that returns tagged pointers on malloc() I
wouldn't expect the programmer to do anything different in the
application code like explicit untagging. Basically the program would
continue to run unmodified irrespective of whether you use an old libc
without tagged pointers or a new one which tags heap allocations.

What I do expect is that the libc checks for the presence of the relaxed
ABI, currently proposed as an AT_FLAGS bit (for MTE we'd have a
HWCAP_MTE), and only tag the malloc() pointers if the kernel supports
the relaxed ABI. As you said, you shouldn't expect that the C library
and kernel are upgraded together, so they should be able to work in any
new/old version combination.

> > > The trouble I see with this is that it is largely theoretical and
> > > requires part of userspace to collude to start using a new CPU feature
> > > that tickles a bug in the kernel. As I understand the golden rule,
> > > this is a bug in the kernel (a missed ioctl() or such) to be fixed,
> > > not a global breaking of some userspace behavior.
> >
> > Yes, we should follow the rule that it's a kernel bug but it doesn't
> > help the user that a newly installed kernel causes user space to no
> > longer reach a prompt. Hence the proposal of an opt-in via personality
> > (for MTE we would need an explicit opt-in by the user anyway since the
> > top byte is no longer ignored but checked against the allocation tag).
> 
> but realistically would this actually get used in this way? or would
> any given system either be MTE or non-MTE. in which case a kernel
> configuration option would seem to make more sense. (because either
> way, the hypothetical user basically needs to recompile the kernel to
> get back on their feet. or all of userspace.)

The two hard requirements I have for supporting any new hardware feature
in Linux are (1) a single kernel image binary continues to run on old
hardware while making use of the new feature if available and (2) old
user space continues to run on new hardware while new user space can
take advantage of the new feature.

The distro user space usually has a hard requirement that it continues
to run on (certain) old hardware. We can't enforce this in the kernel
but we offer the option to user space developers of checking feature
availability through HWCAP bits.

The Android story may be different as you have more control about which
kernel configurations are deployed on specific SoCs. I'm looking more
from a Linux distro angle where you just get an off-the-shelf OS image
and install it on your hardware, either taking advantage of new features
or just not using them if the software was not updated. Or, if updated
software is installed on old hardware, it would just run.

For MTE, we just can't enable it by default since there are applications
who use the top byte of a pointer and expect it to be ignored rather
than failing with a mismatched tag. Just think of a hwasan compiled
binary where TBI is expected to work and you try to run it with MTE
turned on.

I would also expect the C library or dynamic loader to check for the
presence of a HWCAP_MTE bit before starting to tag memory allocations,
otherwise it would get SIGILL on the first MTE instruction it tries to
execute.

> i'm not sure i see this new way for a kernel update to break my system
> and need to be fixed forward/rolled back as any different from any of
> the existing ways in which this can happen :-) as an end-user i have
> to rely on whoever's sending me software updates to test adequately
> enough that they find the problems. as an end user, there isn't any
> difference between "my phone rebooted when i tried to take a photo
> because of a kernel/driver leak", say, and "my phone rebooted when i
> tried to take a photo because of missing untagging of a pointer passed
> via ioctl".
> 
> i suspect you and i have very different people in mind when we say "user" :-)

Indeed, I think we have different users in mind. I didn't mean the end
user who doesn't really care which C library version it's running on
their phone but rather advanced users (not necessarily kernel
developers) that prefer to build their own kernels with every release.
We could extend this to kernel developers who don't have time to track
down why a new kernel triggers lots of SIGSEGVs during boot.

-- 
Catalin

