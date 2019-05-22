Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 076E4C282DE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:21:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4F30217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="GFshwxVj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4F30217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 338EC6B0007; Wed, 22 May 2019 15:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E9496B0008; Wed, 22 May 2019 15:21:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B17C6B000A; Wed, 22 May 2019 15:21:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D620E6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:21:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so2234285pgc.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=NP4JWkHqbCIs5rs8MQbZ/rJv31PHu50+VP85AcMzbbU=;
        b=ieA7l0nSTbtDJR+W1LTinNovtSiRpv7ge2/i6U8n03IQx42sRIsVnACNBFF99C1NlN
         9cDXxpo5ueBkCDh1JvfZJ+RVsGye78f3DOM2DswuCT6+HqDN+4x1i1OXujsgmFqRwhip
         J2x2bmL/9Rvy/hvyayTVm0AAl0nnafatRuHjP754j0wLLTTSXowDtXqWcqvCyVhWZVp6
         5IfuoihweCVkS4MXdZtMmBQSgZEPcHaW+/b7D5yLyu0KAhGEd64HVykhkt4EGqI5mOG+
         iVOitLtekhWi8Rv0tcZ7NFc/NYavLkWErhtnnhiCtVvWFuGHubZ6zQguR4FL1+pgzqbm
         Gppg==
X-Gm-Message-State: APjAAAVvUv8OQq4LJq7W3tHgCXWojbMIOw9kRhwEc/HdD5L26V+Tsvzh
	0hK37qqgdRVQPRXacRudtrljGu0nJzkg/05A11xx8Iz5wNbxRLfxz2BPN7G9hwiUyC9RHNYRlds
	bXKjH1zdwYMgZUxd//47c2kbjqjzpOPUqqCmXBUCWHcpOmcx9ZiCuCPS6lql1o7agFw==
X-Received: by 2002:a17:902:7896:: with SMTP id q22mr1766561pll.129.1558552891344;
        Wed, 22 May 2019 12:21:31 -0700 (PDT)
X-Received: by 2002:a17:902:7896:: with SMTP id q22mr1766496pll.129.1558552890265;
        Wed, 22 May 2019 12:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558552890; cv=none;
        d=google.com; s=arc-20160816;
        b=soy8e6xb+zZ1H/566vIOcE9Zg/rkR+PghiKfnSc2QpmzCdVDhotduCUZXq2TaKkIeO
         2SWd/fVsC+EflKlelIzzQEuTdw07jSHT1GzlWszesvChe4wNmHLJJkoEn33r7ClIZ8+h
         ZIGjQ7TuVy6f7kmz423tpJRt5Qn/LRokdpb54BvwJ3/hNdRGELe6+kG4ik/5uP4Iu5CK
         Pe965PiebCwR4peMslnmVmlyoOrqMnqXcfHv7EYnIM0Ha0vuFr7Vql9qFJLbZLHziMgL
         FoQbbfNhIRMuAeAo6hlf4BcfWXwatn01BT7j749MOEE3LR8GaP98x8DYexZ85RTjzsO6
         OT1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=NP4JWkHqbCIs5rs8MQbZ/rJv31PHu50+VP85AcMzbbU=;
        b=f0mPAGqGXRPJBoPZY7vVfxsb7n/uZUbVO6IKgH+uPZYVsHiAPay46t6KZ5u9LfKA0b
         GXxRxd0NjjfXnLEVzqPSqbDiGznrqHHZ0yMC689JW6iHuhiJMTqyTt1oQ+FNazea+v+j
         JExuSHLGfvBAKTdGU91gpqdonMmlup3P3iWOara2kRdKNroGbcJUyuhjNWU5zfY+W7NN
         85b+52axAgYBi3M0XMd+CVCRwcjvtKaYjxzDVjcokm63zhqDhXEtcfy+vBsf6jQB/SRZ
         3ge85JkdtF7X7PE7Gp3WPco0Ctqy+hsaoGWU15ulwtRH6c39zoJsNdVtK622LDhgc9Kk
         EnGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GFshwxVj;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor27148475pfh.21.2019.05.22.12.21.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 12:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GFshwxVj;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=NP4JWkHqbCIs5rs8MQbZ/rJv31PHu50+VP85AcMzbbU=;
        b=GFshwxVjgFyTBuVsTzhm7IUt1UjnhWPD0MinKNguPB3el83BFNud8bHr5plz3emii+
         cTc7Cjy2KfiVySMa4vl3S45MUDV6ughBv+eP5o9C9KIg6ntk97RzOYluREumaUsuEfOH
         SjJgP3hh0ohPvQPPbSdKkfRYeqkQoVWPqO5e4=
X-Google-Smtp-Source: APXvYqzNjksdiGtBA2K0Yn7lD7hXz0a3WOc+KaCHe5Lfb///NUHl50P+zldmTZ4Tu8MFGQvOw+1qnw==
X-Received: by 2002:a62:6456:: with SMTP id y83mr32990581pfb.71.1558552889913;
        Wed, 22 May 2019 12:21:29 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id x10sm37135797pfj.136.2019.05.22.12.21.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 12:21:28 -0700 (PDT)
Date: Wed, 22 May 2019 12:21:27 -0700
From: Kees Cook <keescook@chromium.org>
To: enh <enh@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
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
Message-ID: <201905221157.A9BAB1F296@keescook>
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

Right -- things should Just Work from the application perspective.

> obviously i'm biased as a libc maintainer, but...
> 
> i don't think it helps to move this to libc --- now you just have an
> extra dependency where to have a guaranteed working system you need to
> update your kernel and libc together. (or at least update your libc to
> understand new ioctls etc _before_ you can update your kernel.)

I think (hope?) we've all agreed that we shouldn't pass this off to
userspace. At the very least, it reduces the utility of MTE, and at worst
it complicates userspace when this is clearly a kernel/architecture issue.

> 
> > > - malloc() starts returning MTE-tagged addresses
> > > - program doesn't break from that change
> > > - program uses some syscall that is missing untagged_addr() and fails
> > > - kernel has now broken userspace that used to work
> >
> > That's one aspect though probably more of a case of plugging in a new
> > device (graphics card, network etc.) and the ioctl to the new device
> > doesn't work.

I think MTE will likely be rather like NX/PXN and SMAP/PAN: there will
be glitches, and we can disable stuff either via CONFIG or (as is more
common now) via a kernel commandline with untagged_addr() containing a
static branch, etc. But I actually don't think we need to go this route
(see below...)

> > The other is that, assuming we reach a point where the kernel entirely
> > supports this relaxed ABI, can we guarantee that it won't break in the
> > future. Let's say some subsequent kernel change (some refactoring)
> > misses out an untagged_addr(). This renders a previously TBI/MTE-capable
> > syscall unusable. Can we rely only on testing?
> >
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

Right: the point is to design things so that we do our best to not break
userspace that is using the new feature (which I think this series has
done well). But supporting MTE/TBI is just like supporting PAN: if someone
refactors a driver and swaps a copy_from_user() to a memcpy(), it's going
to break under PAN. There will be the same long tail of these bugs like
any other, but my sense is that they are small and rare. But I agree:
they're going to be pretty weird bugs to track down. The final result,
however, will be excellent annotation in the kernel for where userspace
addresses get used and people make assumptions about them.

The sooner we get the series landed and gain QEMU support (or real
hardware), the faster we can hammer out these missed corner-cases.
What's the timeline for either of those things, BTW?

> > > I feel like I'm missing something about this being seen as an ABI
> > > break. The kernel already fails on userspace addresses that have high
> > > bits set -- are there things that _depend_ on this failure to operate?
> >
> > It's about providing a relaxed ABI which allows non-zero top byte and
> > breaking it later inadvertently without having something better in place
> > to analyse the kernel changes.

It sounds like the question is how to switch a process in or out of this
ABI (but I don't think that's the real issue: I think it's just a matter
of whether or not a process uses tags at all). Doing it at the prctl()
level doesn't make sense to me, except maybe to detect MTE support or
something. ("Should I tag allocations?") And that state is controlled
by the kernel: the kernel does it or it doesn't.

If a process wants to not tag, that's also up to the allocator where
it can decide not to ask the kernel, and just not tag. Nothing breaks in
userspace if a process is NOT tagging and untagged_addr() exists or is
missing. This, I think, is the core way this doesn't trip over the
golden rule: an old system image will run fine (because it's not
tagging). A *new* system may encounter bugs with tagging because it's a
new feature: this is The Way Of Things. But we don't break old userspace
because old userspace isn't using tags.

So the agreement appears to be between the kernel and the allocator.
Kernel says "I support this" or not. Telling the allocator to not tag if
something breaks sounds like an entirely userspace decision, yes?

-- 
Kees Cook

