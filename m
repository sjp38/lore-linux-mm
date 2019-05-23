Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12AEDC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B81E7206BA
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:45:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B81E7206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489336B0006; Thu, 23 May 2019 10:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 413D46B0007; Thu, 23 May 2019 10:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4D46B0008; Thu, 23 May 2019 10:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBB726B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:45:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so9329372edi.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:45:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ByR+n0+FgeMFtvcbJswV+g8orZFB92ECuCPV2vmRMkk=;
        b=B2vbSE3PUkhj5rLjRnFfoFp9MmOCidglhcABHqpcrg+1YfsaVMnNB0Gi4dWgugFvdB
         HW9l3OUyyBnb1pKzsH5Lh6CNdk64TOTn5SNNnK06y6S6ziCZhN+L0f70wyvlm9f9ufUZ
         NrJ7njIFX33TW7snBeew6hlkM2fNg+U3p3kF7c+ZWnq3nfPKIAS4gxTexlB8AN8KCUa3
         9fb020z0WKKmUgdt/VhENykBqmglPesMdkXN3ohZ/f7DrE3yNw8gdZyO6IkpTRHFhRaG
         fmrU0KSoOciGq+7nhKtz0fLVj5VDsPT5bb5VCGF8MWx6Qh6lGGt4VqxN2LHj4Fsn+bKG
         RFLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVnWzKq/Z1Fjf7xh2tSE62VaG/0SIHuVzaaUQ2N4Rbaahijj6QK
	An6P8LLeqIXLorP8oIMyllBGL/BT4StXv3XnXhY7wG8hL93pnSt2zINWF0X6bpO2ylZ08MuL1bo
	aSdf5Xtsw0BUkn/Egq+RAQxePFNGEfNDtnwQb7gr3Yxx9QbadX2X+WABUQ7x2xOSXCA==
X-Received: by 2002:a05:6402:149a:: with SMTP id e26mr97173075edv.241.1558622701375;
        Thu, 23 May 2019 07:45:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwasHcSURNEXigapb7KfBIqQCM0Ud23oxz/ofN7ElWBOVMdxamiWoMmH1Y0uW2V+rD07va7
X-Received: by 2002:a05:6402:149a:: with SMTP id e26mr97172955edv.241.1558622700306;
        Thu, 23 May 2019 07:45:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558622700; cv=none;
        d=google.com; s=arc-20160816;
        b=sueBwomSKeloK9Qd5zewzoogLkVAN+E09F83B6FTJS4m/x16dUE1REHYjKjA+Xfuib
         ZloZaQ4HlZ+gQ8MOdQTQqVk6xiUvd07FsMOi5Bk5F3fvBWxRLxFVcB673fJJfWpCJudI
         WnGX6jMSHxgPcPiKDF8wct32ylyEuY2wCDmo1emShBOKeLmblVGfRPqo+JaKDHx2H6Dj
         uL+suREDW2yFnow/Tl5eet/nHAOS8tAehz1b+lI/y485NSUoj0RFS8LvFy+QaDOhHjzA
         fSOVZvBCiAGRyznzxDoagtkQMvnR2WCC0tv1x1RuqA03/q8jQYEYneHL04bhmF8fIJEL
         dVMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ByR+n0+FgeMFtvcbJswV+g8orZFB92ECuCPV2vmRMkk=;
        b=PBVRMNgSxfkSzVYj1Y8JAD/xBxcOCX/WqIvKNKDKUrKU9mndui/mQn/kRYYucsWmyH
         xLiSnTHfmRqMYxLkBhBXsvtEvt18EtcawQqEaA2o4eoOsNjLMumlJysGwWahzLRueV++
         N+2KKNL4TtPaIn71hwCUWtYKIdo93+baObu3besSwYVlvb/Qtcxf6QLaR3FcHcz3CViG
         qjV6yb9JpqFxCSQT4rzTM0/JdPPtLTSM62QnM/H2ex6Tj1bA8H1wPJh/fTamqXsxNUas
         uG2Cr1tYWp03urAuPfmVtCCcSw9YPQGGVypAHvLkXQXWhFNQbpa7Oa0xZ2rpgPkPoDvC
         FSfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 9si4851044edz.10.2019.05.23.07.44.59
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 07:45:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B972A80D;
	Thu, 23 May 2019 07:44:58 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9DF2A3F690;
	Thu, 23 May 2019 07:44:52 -0700 (PDT)
Date: Thu, 23 May 2019 15:44:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: enh <enh@google.com>, Evgenii Stepanov <eugenis@google.com>,
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
Message-ID: <20190523144449.waam2mkyzhjpqpur@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905221316.865581CF@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:47:36PM -0700, Kees Cook wrote:
> On Wed, May 22, 2019 at 05:35:27PM +0100, Catalin Marinas wrote:
> > The two hard requirements I have for supporting any new hardware feature
> > in Linux are (1) a single kernel image binary continues to run on old
> > hardware while making use of the new feature if available and (2) old
> > user space continues to run on new hardware while new user space can
> > take advantage of the new feature.
> 
> Agreed! And I think the series meets these requirements, yes?

Yes. I mentioned this just to make sure people don't expect different
kernel builds for different hardware features.

There is also the obvious requirement which I didn't mention: new user
space continues to run on new/subsequent kernel versions. That's one of
the points of contention for this series (ignoring MTE) with the
maintainers having to guarantee this without much effort. IOW, do the
500K+ new lines in a subsequent kernel version break any user space out
there? I'm only talking about the relaxed TBI ABI. Are the usual LTP,
syskaller sufficient? Better static analysis would definitely help.

> > For MTE, we just can't enable it by default since there are applications
> > who use the top byte of a pointer and expect it to be ignored rather
> > than failing with a mismatched tag. Just think of a hwasan compiled
> > binary where TBI is expected to work and you try to run it with MTE
> > turned on.
> 
> Ah! Okay, here's the use-case I wasn't thinking of: the concern is TBI
> conflicting with MTE. And anything that starts using TBI suddenly can't
> run in the future because it's being interpreted as MTE bits? (Is that
> the ABI concern?

That's another aspect to figure out when we add the MTE support. I don't
think we'd be able to do this without an explicit opt-in by the user.

Or, if we ever want MTE to be turned on by default (i.e. tag checking),
even if everything is tagged with 0, we have to disallow TBI for user
and this includes hwasan. There were a small number of programs using
the TBI (I think some JavaScript compilers tried this). But now we are
bringing in the hwasan support and this can be a large user base. Shall
we add an ELF note for such binaries that use TBI/hwasan?

This series is still required for MTE but we may decide not to relax the
ABI blindly, therefore the opt-in (prctl) or personality idea.

> I feel like we got into the weeds about ioctl()s and one-off bugs...)

This needs solving as well. Most driver developers won't know why
untagged_addr() is needed unless we have more rigorous types or type
annotations and a tool to check them (we should probably revive the old
sparse thread).

> So there needs to be some way to let the kernel know which of three
> things it should be doing:
> 1- leaving userspace addresses as-is (present)
> 2- wiping the top bits before using (this series)

(I'd say tolerating rather than wiping since get_user still uses the tag
in the current series)

The current series does not allow any choice between 1 and 2, the
default ABI basically becomes option 2.

> 3- wiping the top bits for most things, but retaining them for MTE as
>    needed (the future)

2 and 3 are not entirely compatible as a tagged pointer may be checked
against the memory colour by the hardware. So you can't have hwasan
binary with MTE enabled.

> I expect MTE to be the "default" in the future. Once a system's libc has
> grown support for it, everything will be trying to use MTE. TBI will be
> the special case (but TBI is effectively a prerequisite).

The kernel handling of tagged pointers is indeed a prerequisite. The ABI
distinction between the above 2 and 3 needs to be solved.

> AFAICT, the only difference I see between 2 and 3 will be the tag handling
> in usercopy (all other places will continue to ignore the top bits). Is
> that accurate?

Yes, mostly (for the kernel). If MTE is enabled by default for a hwasan
binary, it will SEGFAULT (either in user space or in kernel uaccess).
How does the kernel choose between 2 and 3?

> Is "1" a per-process state we want to keep? (I assume not, but rather it
> is available via no TBI/MTE CONFIG or a boot-time option, if at all?)

Possibly, though not necessarily per process. For testing or if
something goes wrong during boot, a command line option with a static
label would do. The AT_FLAGS bit needs to be checked by user space. My
preference would be per-process.

> To choose between "2" and "3", it seems we need a per-process flag to
> opt into TBI (and out of MTE).

Or leave option 2 the default and get it to opt in to MTE.

> For userspace, how would a future binary choose TBI over MTE? If it's
> a library issue, we can't use an ELF bit, since the choice may be
> "late" after ELF load (this implies the need for a prctl().) If it's
> binary-only ("built with HWKASan") then an ELF bit seems sufficient.
> And without the marking, I'd expect the kernel to enforce MTE when
> there are high bits.

The current plan is that a future binary issues a prctl(), after
checking the HWCAP_MTE bit (as I replied to Elliot, the MTE instructions
are not in the current NOP space). I'd expect this to be done by the
libc or dynamic loader under the assumption that the binaries it loads
do _not_ use the top pointer byte for anything else. With hwasan
compiled objects this gets more confusing (any ELF note to identify
them?).

(there is also the risk of existing applications using TBI already but
I'm not aware of any still using this feature other than hwasan)

-- 
Catalin

