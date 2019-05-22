Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9881CC18E7C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 00:04:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 423D9217D9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 00:04:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Zf9QLE33"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 423D9217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2BAD6B0003; Tue, 21 May 2019 20:04:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4F76B0006; Tue, 21 May 2019 20:04:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B567D6B0007; Tue, 21 May 2019 20:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 777066B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 20:04:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id l95so212184plb.8
        for <linux-mm@kvack.org>; Tue, 21 May 2019 17:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=h+HMpjJbOByDkcgcmqTFcjwM/Zjfkc20s8NGwt76Mr8=;
        b=bBeW5t5FZyeiTYmaaIIbKoSa6+J0gHl6AXipwdEdIXPWb9aGxvLnoUjcBZgjMUGAl6
         axf5aNr0RNK/eNIGvMTB0I5gIywqXWmj32zkh0vK+RwmjDouhRIjtIMOYvlUnD2vtS46
         PeLCzGWcg0CxCmNKVOrHU5qZ06J0X54ZQ3PUcX0uWXPTumiDqu/TkebFJaIXFTw7+bE5
         gOew83FuWhKFG3F8i02/OvA/667MB7/T3MH/REmCzWVaAl4FcE+TJpGSMYJ3mh8jw1Hu
         4St5y3HZbAJb71iTOIFVnheUC0fb+pFl+K6fXbY/zPpxwmkRMVe1/TKp1HqRtAS3cJwN
         DKKA==
X-Gm-Message-State: APjAAAWDzgMj0amfLmHUZrnpGpFhwouYjvdwY45pBYN+h36Gpx4I8sl5
	ndsZWN7a5T70jfNQ9NTbYNbcqNe7crsTp7hjhOoiDjxFNw8DlcBgQEuDP+RnhbpWAJOrEkddbHN
	jvikoJz3b47M5G0lYCkZxrw23+w8qJ7XLvaJ20lOfmw9GOvDnEjFQ9bV6dw3ZE42CBQ==
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr88265954plz.128.1558483483910;
        Tue, 21 May 2019 17:04:43 -0700 (PDT)
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr88265884plz.128.1558483482830;
        Tue, 21 May 2019 17:04:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558483482; cv=none;
        d=google.com; s=arc-20160816;
        b=RezCP8hgW/P44P+Jojot942Cu0KPq/WdwYXGgP/QbLKAoesudzHtPgK2GTuXJI9ieh
         tPTvRx0BWHkQVijVTCdo4veuw+vKw3ZUNqgoF96X9Q/lSvSWmy+obNVdpTGn4jj8mZyu
         TzOFZ6F6UE+fvpoK0/Dm3pzfqfXJj2RehDCIZN00Esw6TGBz1ZaSStlleT4/dLC23DRM
         Lksgc80fgDGSKMRF5suNc94lLDB5p0Iv9dXnM1KIW6Dyfh2/C/ZmnT0SHtlMLvBPrNEz
         g638PhayZzEf0whwlu7J71wbFANECYw3Wy1ObPa/siX540Au4rET71aPYZlps6Iin1tB
         1DcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=h+HMpjJbOByDkcgcmqTFcjwM/Zjfkc20s8NGwt76Mr8=;
        b=rP3KWVQnV/vfEKPLSSc7zc8Xb0mHCSFFm9YfsYiKGi0vVmznOzFXyhmAji32AH+m5d
         k9p6/TAkNH9Gx511Pg7MSxzJ0y/QjB6oRHUWpMbvV+90oWpICY2ktclFt/MJFAA9iieL
         uRIHqvryho6HgwMZO4/E2Ox2Xh0xmShfoehc+kTuw+YN5FpVuZXUp/gJn+sFmx4eqOh/
         xgOX2CMt1SN1UUe63kDvM0bzOQo6cgcpvIz/VlvuHZwQhL9ZQx21Cw/BRss4YLQ0uUFa
         W3cm9cXdILXKp6KBOmjTopAiB3htMSOlNwG1eZm7XMgI7nIiJ7Ycxm78V3g56QgPXuag
         DjZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Zf9QLE33;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor22686925pgp.16.2019.05.21.17.04.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 17:04:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Zf9QLE33;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=h+HMpjJbOByDkcgcmqTFcjwM/Zjfkc20s8NGwt76Mr8=;
        b=Zf9QLE33qmPluiR2OGF4dL2quucaUAVgN4YPizfJiTzAzfLxxGI5FlE9xizVc831A4
         PZROfhtKhT/R7pMFQlHGrknlILzZeG3LHD5gyBNKzIo1iuXRcoC6OuM/wsNOYEBlL6Lp
         KGXm5hniO64celTxThJARG41BLIiM0pmyycsI=
X-Google-Smtp-Source: APXvYqyRHlp4k1ARvHRDx6pnXWJEks1ZEDsNIbDRibBeuJSxc6NZrbRUP3gWhA9hXypH8RUrMs25NQ==
X-Received: by 2002:a63:8dc8:: with SMTP id z191mr87505404pgd.9.1558483482349;
        Tue, 21 May 2019 17:04:42 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id a11sm15675685pff.128.2019.05.21.17.04.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 17:04:40 -0700 (PDT)
Date: Tue, 21 May 2019 17:04:39 -0700
From: Kees Cook <keescook@chromium.org>
To: Catalin Marinas <catalin.marinas@arm.com>
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
Message-ID: <201905211633.6C0BF0C2@keescook>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521182932.sm4vxweuwo5ermyd@mbp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 07:29:33PM +0100, Catalin Marinas wrote:
> On Mon, May 20, 2019 at 04:53:07PM -0700, Evgenii Stepanov wrote:
> > On Fri, May 17, 2019 at 7:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > IMO (RFC for now), I see two ways forward:
> > > [...]
> > > 2. Similar shim to the above libc wrapper but inside the kernel
> > >    (arch/arm64 only; most pointer arguments could be covered with an
> > >    __SC_CAST similar to the s390 one). There are two differences from
> > >    what we've discussed in the past:
> > >
> > >    a) this is an opt-in by the user which would have to explicitly call
> > >       prctl(). If it returns -ENOTSUPP etc., the user won't be allowed
> > >       to pass tagged pointers to the kernel. This would probably be the
> > >       responsibility of the C lib to make sure it doesn't tag heap
> > >       allocations. If the user did not opt-in, the syscalls are routed
> > >       through the normal path (no untagging address shim).
> > >
> > >    b) ioctl() and other blacklisted syscalls (prctl) will not accept
> > >       tagged pointers (to be documented in Vicenzo's ABI patches).
> >
> > The way I see it, a patch that breaks handling of tagged pointers is
> > not that different from, say, a patch that adds a wild pointer
> > dereference. Both are bugs; the difference is that (a) the former
> > breaks a relatively uncommon target and (b) it's arguably an easier
> > mistake to make. If MTE adoption goes well, (a) will not be the case
> > for long.
> 
> It's also the fact such patch would go unnoticed for a long time until
> someone exercises that code path. And when they do, the user would be
> pretty much in the dark trying to figure what what went wrong, why a
> SIGSEGV or -EFAULT happened. What's worse, we can't even say we fixed
> all the places where it matters in the current kernel codebase (ignoring
> future patches).

So, looking forward a bit, this isn't going to be an ARM-specific issue
for long. In fact, I think we shouldn't have arm-specific syscall wrappers
in this series: I think untagged_addr() should likely be added at the
top-level and have it be a no-op for other architectures. So given this
becoming a kernel-wide multi-architecture issue (under the assumption
that x86, RISC-V, and others will gain similar TBI or MTE things),
we should solve it in a way that we can re-use.

We need something that is going to work everywhere. And it needs to be
supported by the kernel for the simple reason that the kernel needs to
do MTE checks during copy_from_user(): having that information stripped
means we lose any userspace-assigned MTE protections if they get handled
by the kernel, which is a total non-starter, IMO.

As an aside: I think Sparc ADI support in Linux actually side-stepped
this[1] (i.e. chose "solution 1"): "All addresses passed to kernel must
be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI
for kernel code.") I think this was a mistake we should not repeat for
arm64 (we do seem to be at least in agreement about this, I think).

[1] https://lore.kernel.org/patchwork/patch/654481/

> > This is a bit of a chicken-and-egg problem. In a world where memory
> > allocators on one or several popular platforms generate pointers with
> > non-zero tags, any such breakage will be caught in testing.
> > Unfortunately to reach that state we need the kernel to start
> > accepting tagged pointers first, and then hold on for a couple of
> > years until userspace catches up.
> 
> Would the kernel also catch up with providing a stable ABI? Because we
> have two moving targets.
> 
> On one hand, you have Android or some Linux distro that stick to a
> stable kernel version for some time, so they have better chance of
> clearing most of the problems. On the other hand, we have mainline
> kernel that gets over 500K lines every release. As maintainer, I can't
> rely on my testing alone as this is on a limited number of platforms. So
> my concern is that every kernel release has a significant chance of
> breaking the ABI, unless we have a better way of identifying potential
> issues.

I just want to make sure I fully understand your concern about this
being an ABI break, and I work best with examples. The closest situation
I can see would be:

- some program has no idea about MTE
- malloc() starts returning MTE-tagged addresses
- program doesn't break from that change
- program uses some syscall that is missing untagged_addr() and fails
- kernel has now broken userspace that used to work

The trouble I see with this is that it is largely theoretical and
requires part of userspace to collude to start using a new CPU feature
that tickles a bug in the kernel. As I understand the golden rule,
this is a bug in the kernel (a missed ioctl() or such) to be fixed,
not a global breaking of some userspace behavior.

I feel like I'm missing something about this being seen as an ABI
break. The kernel already fails on userspace addresses that have high
bits set -- are there things that _depend_ on this failure to operate?

-- 
Kees Cook

