Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 507C5C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:31:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06918217D9
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:31:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SXshT/JW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06918217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FE8C6B0003; Thu, 23 May 2019 17:31:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AF9A6B0005; Thu, 23 May 2019 17:31:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 776716B0006; Thu, 23 May 2019 17:31:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB0E6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:31:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so4730137pga.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:31:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=RooTx4nZ0Zm8m1fxzq6UPxwDmwN2R9frxfJHiTxcRUE=;
        b=D1GnFZGzanwDyXHNGVXxm+J33O0bWGpxzoMGfoBNT2JOB+AN3dK3O+qTwxHVXLjyJ+
         vLOA+ZO59gIA/lI/EV/TFBSMG8ecUqG4Brq3PI2qd+eQHYxdFycc32qC3vgiUkzj1fxs
         elE2um+SmBkGZsghTdY1ueLYj7sOve7wVH3XjVB9dVF2sY3BAZiqZyU3LzZMx4++Ovf4
         3rQDHaK6cer1NGkjEzjGJ+c7mRwdmfdtk5jRfZVaaSsssGfe7W0eHlkST8elpHS4q4ef
         ZBARsxR3sW8IaszMayltqIrpv51y4dDmGrM/fNdXcTHiFLtvRKAYtZTFCjb98dxYBtLw
         wiEg==
X-Gm-Message-State: APjAAAU0KMQ+AJqazMmgT0pMma86HF5141joIhbwtewPq9GzWJscPmti
	2aotjNfpJ8VSJB7N8AO6bBp0DSdMhF3W0wxdcpqyPjgvYCE51QK7Gs0pKOGz03Hh22rPFC/WWPc
	tCtfyfhzpEcDBBPSbrEYMtxgUJwiT1aKki07gEG4QjRGfj/5A+8X6s/nWMTclBHF7og==
X-Received: by 2002:a65:63c8:: with SMTP id n8mr1951021pgv.96.1558647080590;
        Thu, 23 May 2019 14:31:20 -0700 (PDT)
X-Received: by 2002:a65:63c8:: with SMTP id n8mr1950924pgv.96.1558647079575;
        Thu, 23 May 2019 14:31:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558647079; cv=none;
        d=google.com; s=arc-20160816;
        b=M8NQDhtLv/KpYvbOKp/X89t+CMK1lR/K98fTMkezVV3i6/HgAPXi9fzSP9AkPIzRwe
         VF0IxDTZzGWjHlxpv2cRwWtQrvzZcpfLKdRlwNQWvcOpFaWvF05VVJqzxyQ3R/yZJ7JP
         P1ySgelwbHf+kvfuWc2eebPsKmQUxoqkzGU0Z3jL/2pakXds7dqsLbt4mBfPbSUNMr3q
         1a2MIaIUCbHlzke7ecdvtSYzCwFA6T2pDakKFrmmC74F7do59GQKnHVI5Dg8bsUWV7bh
         hZH0WeRUTbDGgxb6+8kG87VhDJW0A+D31580h/aaNtmq5EdFfp5T8TDzEosTYFrClzw+
         iQ2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=RooTx4nZ0Zm8m1fxzq6UPxwDmwN2R9frxfJHiTxcRUE=;
        b=eZmghQg+UkCWCGWcA5vzmOTpmrV/rmuhzPLNTMVPRc6yMzZaTZBOdMycTUGMe161xM
         Iixu5NycSx6PgXH1eKxLGrR6PihNLmTyrRyfO8HakjYGX8wIoQ9YZKjyGR4vTcZgwMAj
         7MBVRWKgbzxKck2SlSCIZCXD4kMJ/pCB18sfyu7ZMUglH8epczkxQwkrlwyd72S0hmWy
         RXdMs2Gm5byAVX+FY4DTSs4tNShenmg7TqAVdjmhvUSWJybsylJXrP5lV8KTTjPnWRX3
         JMYejeWPWprnIWTCCfCBnmJWeJFp4wmIGcpSBUOkdd+oSExn6hysfl2mYIqYAQ+OqoeP
         cIhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="SXshT/JW";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor649038pgt.65.2019.05.23.14.31.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 14:31:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="SXshT/JW";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=RooTx4nZ0Zm8m1fxzq6UPxwDmwN2R9frxfJHiTxcRUE=;
        b=SXshT/JWt4/VxFaxzUCPBis/uU7CKJhnvqILKuBvKuHgZM/0X3lQPlS9BrcA9GPwgN
         mNP52DBHjW70HoXLGw3kCTAML6GHF8r2zv6T7pohAbgiWS2GBzlP+CcIwmEuaO+qZxq4
         C2Jko0HEb2Ra0I9vlZLyIy+YOud56hz3nr/kE=
X-Google-Smtp-Source: APXvYqw6NOt/dAzFGypTG6hDOH9RhK81m8D3qkjrLvBMN1nJLO77YhSc++d1DOA7/Z/CI2DiFH6JYA==
X-Received: by 2002:a63:2226:: with SMTP id i38mr5980879pgi.403.1558647079048;
        Thu, 23 May 2019 14:31:19 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id f186sm406654pfb.5.2019.05.23.14.31.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 14:31:17 -0700 (PDT)
Date: Thu, 23 May 2019 14:31:16 -0700
From: Kees Cook <keescook@chromium.org>
To: Catalin Marinas <catalin.marinas@arm.com>
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
Message-ID: <201905231327.77CA8D0A36@keescook>
References: <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <201905230917.DEE7A75EF0@keescook>
 <20190523174345.6sv3kcipkvlwfmox@mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523174345.6sv3kcipkvlwfmox@mbp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 06:43:46PM +0100, Catalin Marinas wrote:
> On Thu, May 23, 2019 at 09:38:19AM -0700, Kees Cook wrote:
> > What on this front would you be comfortable with? Given it's a new
> > feature isn't it sufficient to have a CONFIG (and/or boot option)?
> 
> I'd rather avoid re-building kernels. A boot option would do, unless we
> see value in a per-process (inherited) personality or prctl. The

I think I've convinced myself that the normal<->TBI ABI control should
be a boot parameter. More below...

> > What about testing tools that intentionally insert high bits for syscalls
> > and are _expecting_ them to fail? It seems the TBI series will break them?
> > In that case, do we need to opt into TBI as well?
> 
> If there are such tools, then we may need a per-process control. It's
> basically an ABI change.

syzkaller already attempts to randomly inject non-canonical and
0xFFFF....FFFF addresses for user pointers in syscalls in an effort to
find bugs like CVE-2017-5123 where waitid() via unchecked put_user() was
able to write directly to kernel memory[1].

It seems that using TBI by default and not allowing a switch back to
"normal" ABI without a reboot actually means that userspace cannot inject
kernel pointers into syscalls any more, since they'll get universally
stripped now. Is my understanding correct, here? i.e. exploiting
CVE-2017-5123 would be impossible under TBI?

If so, then I think we should commit to the TBI ABI and have a boot
flag to disable it, but NOT have a process flag, as that would allow
attackers to bypass the masking. The only flag should be "TBI or MTE".

If so, can I get top byte masking for other architectures too? Like,
just to strip high bits off userspace addresses? ;)

(Oh, in looking I see this is implemented with sign-extension... why
not just a mask? So it'll either be valid userspace address or forced
into the non-canonical range?)

[1] https://salls.github.io/Linux-Kernel-CVE-2017-5123/

> > Alright, the tl;dr appears to be:
> > - you want more assurances that we can find __user stripping in the
> >   kernel more easily. (But this seems like a parallel problem.)
> 
> Yes, and that we found all (most) cases now. The reason I don't see it
> as a parallel problem is that, as maintainer, I promise an ABI to user
> and I'd rather stick to it. I don't want, for example, ncurses to stop
> working because of some ioctl() rejecting tagged pointers.

But this is what I don't understand: it would need to be ncurses _using
TBI_, that would stop working (having started to work before, but then
regress due to a newly added one-off bug). Regular ncurses will be fine
because it's not using TBI. So The Golden Rule isn't violated, and by
definition, it's a specific regression caused by some bug (since TBI
would have had to have worked _before_ in the situation to be considered
a regression now). Which describes the normal path for kernel
development... add feature, find corner cases where it doesn't work,
fix them, encounter new regressions, fix those, repeat forever.

> If it's just the occasional one-off bug I'm fine to deal with it. But
> no-one convinced me yet that this is the case.

You believe there still to be some systemic cases that haven't been
found yet? And even if so -- isn't it better to work on that
incrementally?

> As for the generic driver code (filesystems or other subsystems),
> without some clear direction for developers, together with static
> checking/sparse, on how user pointers are cast to longs (one example),
> it would become my responsibility to identify and fix them up with any
> kernel release. This series is not providing such guidance, just adding
> untagged_addr() in some places that we think matter.

What about adding a nice bit of .rst documentation that describes the
situation and shows how to use untagged_addr(). This is the kind of
kernel-wide change that "everyone" needs to know about, and shouldn't
be the arch maintainer's sole responsibility to fix.

> > - we might need to opt in to TBI with a prctl()
> 
> Yes, although still up for discussion.

I think I've talked myself out of it. I say boot param only! :)


So what do you say to these next steps:

- change untagged_addr() to use a static branch that is controlled with
  a boot parameter.
- add, say, Documentation/core-api/user-addresses.rst to describe
  proper care and handling of user space pointers with untagged_addr(),
  with examples based on all the cases seen so far in this series.
- continue work to improve static analysis.

Thanks for wading through this with me! :)

-- 
Kees Cook

