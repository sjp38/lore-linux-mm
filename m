Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69341C193F2
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C4DC21841
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:11:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C4DC21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2B216B026B; Wed, 22 May 2019 06:11:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DB8C6B026C; Wed, 22 May 2019 06:11:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 855726B026D; Wed, 22 May 2019 06:11:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3450C6B026B
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:11:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so2939279eda.11
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:11:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WDLeSRtafs//OE8zGzjuDzmDTHfsQOJOsFRN/Kb0/6g=;
        b=UqSVMnVtTr3fH/bhTOVR7noKMbGwML3G90Q847yPRwzK1Sgewx7WTRGhB4L+plOWUz
         P9w1Mi4fAjv/Fzmr/UG1TAnX39cu/+5N20kguOy5POOJ1MPcBhEP4qhLfOekuK27bnFQ
         O9lP6ZloamZ61pIqPEvj1dLB/FdCIWPsR4GdpN6sXqPST7g9HlIpmtMEs6KXs4jUMPwN
         OY4tw7rqfBx0DJEOXts2PA+nsKW0V488U6mxR17SdJcTaUgVmlT0XL0Di32oULtLUO8G
         2clKv/ty6iR9ivLZo4AfcezqzdC4pyAdcWAdbJEhWnvNyC2wcgXoQJui20/K6cuZIhT0
         dnng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXdRrUjR5TuK+Oy0UMHCkg+LuRDUeaOyZig1s0HNUuIWYgFYrYv
	Cnn8G+/Bjn8Giz7MRnGV+R9BU8KINymiPwiS+PBjAGQNrlCzTGGhKs9dUlRHDE8SidJCqlIFik4
	ObouBpNHw+tfgK2Ix7EpioxyFHZkUFvYXOm9dZgc5rvFg0ep0Da+Mo/1jcuUukJfNXA==
X-Received: by 2002:a50:99ca:: with SMTP id n10mr88883760edb.279.1558519882708;
        Wed, 22 May 2019 03:11:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBpMlES92KGz22UU4YL343hoXB1Xd04dNEX25KPHOKWu3ZfLuFpUNAApWpZwhnXyNLlEoZ
X-Received: by 2002:a50:99ca:: with SMTP id n10mr88883640edb.279.1558519881455;
        Wed, 22 May 2019 03:11:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519881; cv=none;
        d=google.com; s=arc-20160816;
        b=Tp9UGzF51tdcb/PUuxAN5jeCLwohu1eoG+wu+4r5O81VR2vZ19g117wGFQoHXtMqXs
         BxRmIv0WZ/aSpbJyNUM1Tcw/Ud5AaAOCeCW7MYW8d8GAYMU82dOY396RBWYTRhjdTqnf
         uydxHbJuycS34EB3PVBjG7uWDn1+d8jX2opSQBb+77WETqzqywJZGxtQrw5N+wdk4Njt
         dJR0QMAub3b9BN4fEz33LlIPKw8aivQeMZghj/8Jy2ECPyhjbjUFqXVWqrZQU4c7abSr
         OnGow5+czPuQb5xYlEGWJf6pjwvYAsyoVlznrao5dnySNWfv3grrnMe/Kwa8Q9IfmYyL
         TCdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WDLeSRtafs//OE8zGzjuDzmDTHfsQOJOsFRN/Kb0/6g=;
        b=RjS0q1dRppqle/2Z3zHTROZ7uGKO5aUrwCBsxCaLU9dF3CcFpfuC1EzNG0spt+Xter
         bZgItxCfad5XIWeNxz0UPkZNHw572rdzL/x5jpJUYuMwset2vJJMDDKOpfK2+I3fnJE0
         W+OsRpwQpv04xvsrpx0cNZQsw40g++QPXhYBrgC9E7LtE7Cozws0n8eK2AncWq5fREAP
         4s6sRkdkfBv77hawWhx+zvq/HuwygzGVw82Cr7TRq/+GoxDnSiOZ2g+bp/jf01zugcQE
         gH6XSg4wLv/Oqkk/s1LAPNbKgE+A/D+ayejsyj6oR5kgiEt39yWwG/DxmOeZhq/HdEIh
         1SMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p37si5646924eda.85.2019.05.22.03.11.21
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 03:11:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2B39E341;
	Wed, 22 May 2019 03:11:20 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 12BA73F575;
	Wed, 22 May 2019 03:11:13 -0700 (PDT)
Date: Wed, 22 May 2019 11:11:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: Evgenii Stepanov <eugenis@google.com>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190522101110.m2stmpaj7seezveq@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905211633.6C0BF0C2@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kees,

Thanks for joining the thread ;).

On Tue, May 21, 2019 at 05:04:39PM -0700, Kees Cook wrote:
> On Tue, May 21, 2019 at 07:29:33PM +0100, Catalin Marinas wrote:
> > On Mon, May 20, 2019 at 04:53:07PM -0700, Evgenii Stepanov wrote:
> > > On Fri, May 17, 2019 at 7:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > IMO (RFC for now), I see two ways forward:
> > > > [...]
> > > > 2. Similar shim to the above libc wrapper but inside the kernel
> > > >    (arch/arm64 only; most pointer arguments could be covered with an
> > > >    __SC_CAST similar to the s390 one). There are two differences from
> > > >    what we've discussed in the past:
> > > >
> > > >    a) this is an opt-in by the user which would have to explicitly call
> > > >       prctl(). If it returns -ENOTSUPP etc., the user won't be allowed
> > > >       to pass tagged pointers to the kernel. This would probably be the
> > > >       responsibility of the C lib to make sure it doesn't tag heap
> > > >       allocations. If the user did not opt-in, the syscalls are routed
> > > >       through the normal path (no untagging address shim).
> > > >
> > > >    b) ioctl() and other blacklisted syscalls (prctl) will not accept
> > > >       tagged pointers (to be documented in Vicenzo's ABI patches).
> > >
> > > The way I see it, a patch that breaks handling of tagged pointers is
> > > not that different from, say, a patch that adds a wild pointer
> > > dereference. Both are bugs; the difference is that (a) the former
> > > breaks a relatively uncommon target and (b) it's arguably an easier
> > > mistake to make. If MTE adoption goes well, (a) will not be the case
> > > for long.
> > 
> > It's also the fact such patch would go unnoticed for a long time until
> > someone exercises that code path. And when they do, the user would be
> > pretty much in the dark trying to figure what what went wrong, why a
> > SIGSEGV or -EFAULT happened. What's worse, we can't even say we fixed
> > all the places where it matters in the current kernel codebase (ignoring
> > future patches).
> 
> So, looking forward a bit, this isn't going to be an ARM-specific issue
> for long.

I do hope so.

> In fact, I think we shouldn't have arm-specific syscall wrappers
> in this series: I think untagged_addr() should likely be added at the
> top-level and have it be a no-op for other architectures.

That's what the current patchset does, so we have this as a starting
point. Kostya raised another potential issue with the syscall wrappers:
with MTE the kernel will be forced to enable the match-all (wildcard)
pointers for user space accesses since copy_from_user() would only get a
0 tag. So it has wider implications than just uaccess routines not
checking the colour.

> So given this becoming a kernel-wide multi-architecture issue (under
> the assumption that x86, RISC-V, and others will gain similar TBI or
> MTE things), we should solve it in a way that we can re-use.

Can we do any better to aid the untagged_addr() placement (e.g. better
type annotations, better static analysis)? We have to distinguish
between user pointers that may be dereferenced by the kernel (I think
almost fully covered with this patchset) and user addresses represented
as ulong that may:

a) be converted to a user pointer and dereferenced; I think that's the
   case for many overloaded ulong/u64 arguments

b) used for address space management, rbtree look-ups etc. where the tag
   is no longer relevant and it even gets in the way

We tried last year to identify void __user * casts to unsigned long
using sparse on the assumption that pointers can be tagged while ulong
is about address space management and needs to lose such tag. I think we
could have pushed this further. For example, get_user_pages() takes an
unsigned long but it is perfectly capable of untagging the address
itself. Shall we change its first argument to void __user * (together
with all its callers)?

find_vma(), OTOH, could untag the address but it doesn't help since
vm_start/end don't have such information (that's more about the content
or type that the user decided) and the callers check against it.

Are there any other places where this matters? These patches tracked
down find_vma() as some heuristics but we may need better static
analysis to identify other cases.

> We need something that is going to work everywhere. And it needs to be
> supported by the kernel for the simple reason that the kernel needs to
> do MTE checks during copy_from_user(): having that information stripped
> means we lose any userspace-assigned MTE protections if they get handled
> by the kernel, which is a total non-starter, IMO.

Such feedback is welcomed ;).

> As an aside: I think Sparc ADI support in Linux actually side-stepped
> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel must
> be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI
> for kernel code.") I think this was a mistake we should not repeat for
> arm64 (we do seem to be at least in agreement about this, I think).
> 
> [1] https://lore.kernel.org/patchwork/patch/654481/

I tried to drag the SPARC guys into this discussion but without much
success.

> > > This is a bit of a chicken-and-egg problem. In a world where memory
> > > allocators on one or several popular platforms generate pointers with
> > > non-zero tags, any such breakage will be caught in testing.
> > > Unfortunately to reach that state we need the kernel to start
> > > accepting tagged pointers first, and then hold on for a couple of
> > > years until userspace catches up.
> > 
> > Would the kernel also catch up with providing a stable ABI? Because we
> > have two moving targets.
> > 
> > On one hand, you have Android or some Linux distro that stick to a
> > stable kernel version for some time, so they have better chance of
> > clearing most of the problems. On the other hand, we have mainline
> > kernel that gets over 500K lines every release. As maintainer, I can't
> > rely on my testing alone as this is on a limited number of platforms. So
> > my concern is that every kernel release has a significant chance of
> > breaking the ABI, unless we have a better way of identifying potential
> > issues.
> 
> I just want to make sure I fully understand your concern about this
> being an ABI break, and I work best with examples. The closest situation
> I can see would be:
> 
> - some program has no idea about MTE

Apart from some libraries like libc (and maybe those that handle
specific device ioctls), I think most programs should have no idea about
MTE. I wouldn't expect programmers to have to change their app just
because we have a new feature that colours heap allocations.

> - malloc() starts returning MTE-tagged addresses
> - program doesn't break from that change
> - program uses some syscall that is missing untagged_addr() and fails
> - kernel has now broken userspace that used to work

That's one aspect though probably more of a case of plugging in a new
device (graphics card, network etc.) and the ioctl to the new device
doesn't work.

The other is that, assuming we reach a point where the kernel entirely
supports this relaxed ABI, can we guarantee that it won't break in the
future. Let's say some subsequent kernel change (some refactoring)
misses out an untagged_addr(). This renders a previously TBI/MTE-capable
syscall unusable. Can we rely only on testing?

> The trouble I see with this is that it is largely theoretical and
> requires part of userspace to collude to start using a new CPU feature
> that tickles a bug in the kernel. As I understand the golden rule,
> this is a bug in the kernel (a missed ioctl() or such) to be fixed,
> not a global breaking of some userspace behavior.

Yes, we should follow the rule that it's a kernel bug but it doesn't
help the user that a newly installed kernel causes user space to no
longer reach a prompt. Hence the proposal of an opt-in via personality
(for MTE we would need an explicit opt-in by the user anyway since the
top byte is no longer ignored but checked against the allocation tag).

> I feel like I'm missing something about this being seen as an ABI
> break. The kernel already fails on userspace addresses that have high
> bits set -- are there things that _depend_ on this failure to operate?

It's about providing a relaxed ABI which allows non-zero top byte and
breaking it later inadvertently without having something better in place
to analyse the kernel changes.

Thanks.

-- 
Catalin

