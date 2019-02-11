Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BED8C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:35:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F7820838
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:35:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F7820838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFA5F8E00C4; Mon, 11 Feb 2019 06:35:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA8388E00C3; Mon, 11 Feb 2019 06:35:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B712C8E00C4; Mon, 11 Feb 2019 06:35:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58A928E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:35:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so9268898edd.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 03:35:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tywLTa1Y80KksOGIltUBqoR4HQQjpW9kTInn+hR2JLE=;
        b=q2w5VYUju+meowoX1k+SIJBN2l1tf2T3p0YK72bRDvnpfIbxvheCzHfFsLB7kAWDIi
         WWcx0FdNYye6fv0Zv+f4DRcP3keqbw3jDmrC+SWMV/ej/62xn3nfqBPpfRAzMNhqq4jx
         Z4JiXIKt6E7K3YCSr/WNS6n9ltnuxT0asf+XCM/VlBZ6x98WouyjhFEJyCPIpaGHMOg9
         Vb12qcMhlDVREnfuSSub4UC3bY8tvw4GJZbsZwmn8X/0N3LXs18d3V97WYxXurkc1b2h
         c03ULOOleSygqXLbY89GU1FNziUqmGLUg2KWUPNEVIvBGyFj6qtsY2gmoZL7ZV2W2ByN
         k/Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuZVwoZMl4PnwkuwUaQjJGg7o2Nyd3Xy7Hs0hPeqQlGLFwJbnYcY
	9fdC9H2IVhVhpn/otTefSMan6UoYa9EtWnqU8ySG4FhnOU+80aD+ioEYM1i1+1O71qOnasTnaQE
	aihnEzLZwk6RfCPkTVMr+iezkNr7xyahAHV6rzNmBz5NOSt0mutBMJXCH8IulhRCSdg==
X-Received: by 2002:a17:906:364d:: with SMTP id r13mr17276800ejb.183.1549884921739;
        Mon, 11 Feb 2019 03:35:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ02uqzvNOWOaA8qmlO6CXOn5JdQemqU5L/YaEEMMSwBlJUIqyadMSIahnifJad1Yx7HdKw
X-Received: by 2002:a17:906:364d:: with SMTP id r13mr17276725ejb.183.1549884920480;
        Mon, 11 Feb 2019 03:35:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549884920; cv=none;
        d=google.com; s=arc-20160816;
        b=m7WafHn4sywAlYcalpw9i9kmQkDoyoJ/EVhf/Q7/NK1vw+li6ny+1P7oB609WBiAOO
         uU0gyGR98demt3YnP5y7ut4LpWW6waqlRMUN3nbp8lAnNyS4maKlQowR5K/9eHFqe4fw
         +MNGH2FkccNEN8BFuIee8KEgrs4CkLQ9TWLuK3kR2vaJGtQFdpsgZ4ZFRH1G/7hdWezD
         gvlY3H+EihXBolhSfvHq6dqddEi4+Kk41GOXwK1YHg4QuBDPlyD0F+lwKiwiORJVn7f5
         MiVBKk9JoZuWJA7k9vXAuHZd9n1Pqnq0xX0hBZdUf8Qqc7maDC0/wX4SoQ8j2LFw5O7D
         254g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tywLTa1Y80KksOGIltUBqoR4HQQjpW9kTInn+hR2JLE=;
        b=L2y57u1WlGmjAUucu9vnYiMriKq/2HZc+qDXMf7AZxM1DJHjEANgbuc0562iGAcbAc
         iPrNOPfgZUyOJToj2MTPpFfonWsULNdP28vNrHj4AlNN0IOPlylr0dBEvphwTe9cU0lS
         pM+yoiuosrtHlJWf08KRxT8xp5GbtrkOoQZz0+ulZCYrTAguuWzeN2E8StR4nNMY3kve
         40InxbzET7RXiVijUsDQP6OENiudkKwr1Q4Jn/h8iqpzPtOXhducucMbSsDxIIAUYKDQ
         9d8VmLk+O5BaDg4NzpFRVCKY5m7z74Ryexxsm6+1EJ33i1nt01nXgJ1G7qbJfUexyaMT
         8fpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f13si3175828ejd.108.2019.02.11.03.35.20
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 03:35:20 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3DE0B80D;
	Mon, 11 Feb 2019 03:35:19 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 018CF3F557;
	Mon, 11 Feb 2019 03:35:14 -0800 (PST)
Date: Mon, 11 Feb 2019 11:35:12 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org,
	Chintan Pandya <cpandya@codeaurora.org>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v9 0/8] arm64: untag user pointers passed to the kernel
Message-ID: <20190211113511.GA165128@arrakis.emea.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181212170108.GZ3505@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212170108.GZ3505@e103592.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

On Wed, Dec 12, 2018 at 05:01:12PM +0000, Dave P Martin wrote:
> On Mon, Dec 10, 2018 at 01:50:57PM +0100, Andrey Konovalov wrote:
> > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > tags into the top byte of each pointer. Userspace programs (such as
> > HWASan, a memory debugging tool [1]) might use this feature and pass
> > tagged user pointers to the kernel through syscalls or other interfaces.
[...]
> It looks like there's been a lot of progress made here towards smoking
> out most of the sites in the kernel where pointers need to be untagged.

In summary, based on last summer's analysis, there are two main (and
rather broad) scenarios of __user pointers use in the kernel: (a)
uaccess macros, together with access_ok() checks and (b) identifying
of user address ranges (find_vma() and related, some ioctls). The
patches here handle the former by allowing sign-extension in access_ok()
and subsequent uaccess routines work fine with tagged pointers.
Identifying the latter is a bit more problematic and the approach we
took was tracking down pointer to long conversion which seems to cover
the majority of cases. However, this approach doesn't scale as, for
example, we'd rather change get_user_pages() to sign-extend the address
rather than all the callers. In lots of other cases we don't even need
untagging as we don't expect user space to tag such pointers (i.e.
mmap() of device memory).

We might be able to improve the static analysis by introducing a
virt_addr_t but that's significant effort and we still won't cover all
cases (e.g. it doesn't necessarily catch tcp_zerocopy_receive() which
wouldn't use a pointer, just a u64 for address).

> However, I do think that we need a clear policy for how existing kernel
> interfaces are to be interpreted in the presence of tagged pointers.
> Unless we have that nailed down, we are likely to be able to make only
> vague guarantees to userspace about what works, and the ongoing risk
> of ABI regressions and inconsistencies seems high.

I agree.

> Can we define an opt-in for tagged-pointer userspace, that rejects all
> syscalls that we haven't checked and whitelisted (or that are
> uncheckable like ioctl)? 

Defining an opt-in is not a problem, however, rejecting all syscalls
that we haven't whitelisted is not feasible. We can have an opt-in per
process (that's what we were going to do with MTE) but the only thing
we can reasonably do is change the behaviour of access_ok(). That's too
big a knob and a new syscall that we haven't got around to whitelist may
just work. This eventually leads to de-facto ABI and our whitelist would
simply be ignored.

I'm not really keen on a big syscall shim in the arm64 kernel which
checks syscall arguments, including in-struct values. If we are to do
this, I'd rather keep it in user space as part of the C library.

> In the meantime, I think we really need to nail down the kernel's
> policies on
> 
>  * in the default configuration (without opt-in), is the presence of
> non-address bits in pointers exchanged with the kernel simply
> considered broken?  (Even with this series, the de factor answer
> generally seems to be "yes", although many specific things will now
> work fine)

Without these patches, passing non-address bits in pointers is
considered broken. I couldn't find a case where it would still work with
non-zero tag but maybe I haven't looked hard enough.

>  * if not, how do we tighten syscall / interface specifications to
> describe what happens with pointers containing non-address bits, while
> keeping the existing behaviour for untagged pointers?
> 
> We would want a general recipe that gives clear guidance on what
> userspace should expect an arbitrarily chosen syscall to do with its
> pointers, without having to enumerate each and every case.

That's what we are aiming with the pointer origins, to move away from a
syscall whitelist to a generic definition. That said, the two approaches
are orthogonal, we can use the pointer origins as the base rule for
which syscalls can be whitelisted.

If we step back a bit to look at the use-case for TBI (and MTE), the
normal application programmer shouldn't really care about this ABI
(well, most of the time). The app gets a tagged pointer from the C
library as a result of a malloc()/realloc() (possibly alloca()) call and
it expects to be able to pass it back into the kernel (usually via the C
library) without any awareness of the non-address bits. Now, we can't
define a user/kernel ABI based on the provenance of the pointer in user
space (i.e. we only support tags for heap and stack), so we are trying
to generalise this based where the pointer originated from in the kernel
(e.g. anonymous mmap()).

> There may already be some background on these topics -- can you throw me
> a link if so?

That's an interesting sub-thread to read:

https://lore.kernel.org/lkml/5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com/

-- 
Catalin

