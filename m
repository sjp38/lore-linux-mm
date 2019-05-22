Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07946C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:09:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86625206BA
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:09:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="igi2ZowC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86625206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 487ED6B0003; Wed, 22 May 2019 19:09:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 411486B0006; Wed, 22 May 2019 19:09:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D98E6B0007; Wed, 22 May 2019 19:09:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC6B46B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 19:09:45 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id d11so748019lji.21
        for <linux-mm@kvack.org>; Wed, 22 May 2019 16:09:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Zo0ta7cFHgMRhNj415CGcWxBRhsPIdMQaFfQkNGZDyg=;
        b=Cth112LVa38MeBZBLiSMdnewizHpV49EZBf/0Ys15jOAd6Spv5lJZPgEZcS+I2KgjN
         jFwxH4tt45SWrxhgIH6/QV0Y6f6sk8qYMraYtJmaBs1arFG1WKA53d76isUZQMn/we6E
         4tN6N7nkV7GIgEZ9MP3qya88HOc0FE+CWZEMdDjv1qQmpXSdNYCa6Q4ouuzxYkw/qFTI
         ZrNsPf40iHG3ruy3cB0bjtPb9S53VutyebU4xBRlpIqHx+Xwy9S2NaETn2nx5C8L51DM
         87RO8AXtKIbsLcciMdjwT0dYPuh8vNlFQP6Y6xBBMJwkuJ+qhPuGEd9HsQImco+OJgfS
         AqlQ==
X-Gm-Message-State: APjAAAVQOxacYFNpXQnJzEmzdujQxh2meo2+m42Nk7f/J84AughzJ7uG
	h3Kk+ZFkN/Xgpep7Inx+etKlgcEalLV9DVM/OA1+YSW+CqCN06svcV3bacKkclxKD5Itjsos7ns
	3NkyjNtNAQozp7XZibfP/D85NmIgzx/zwPvYKSuXmA0BBV7yW0aM4/Y/eICBnfBZb9w==
X-Received: by 2002:a2e:89cb:: with SMTP id c11mr14027721ljk.16.1558566585056;
        Wed, 22 May 2019 16:09:45 -0700 (PDT)
X-Received: by 2002:a2e:89cb:: with SMTP id c11mr14027680ljk.16.1558566584061;
        Wed, 22 May 2019 16:09:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558566584; cv=none;
        d=google.com; s=arc-20160816;
        b=kQxZioKXNJuedXykaJ6sOlFSM0tYtYpR99pLyT5q8HeRZCoWSCt/269O80sjs8KC0l
         4vE2oixjY2k6XpOdQFEpbDZ0bzKgUtYaK6dEsfc7mOPrrAHzMgUIN8SowhEz/OXvEBxW
         HruISqYuoEEAEcdkNCrU8DldIDS/1kTbRgYGmhkWg95usEId36ut5netCuVjDc1s6rIb
         b6Q2f3X4+8g2/CtEaPf6b+QLGJ4SkbwkLOkYGlxQCLGdlxCfcPIidCZ4eaIluVqpgmur
         rCeFdlgMLM9JFFAio3MFjECQbRQIDJLaAiLDUWSqzVFLz35sK0FdKFkZ53/rmOhvBgMe
         dPHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Zo0ta7cFHgMRhNj415CGcWxBRhsPIdMQaFfQkNGZDyg=;
        b=nJWpfglVsPaJl/K5JHPu7aY/WrUphu06kgU4OlZzudmUyS+iwDDmnDYthdHwhcd1c9
         ZwF7GdPPHHcIdRn9Q86FfFcgXDQfXNXmwuOFHc+FBgec7wR5O2rSCDD8vEAy5GCPbThT
         z2xa8+N25TLyo9HWavsnYJMSISvxBLc5EHBenUbl4YfHl+mV5fVehTQxhh8IVoKgNdqY
         JQ9cquNTT+1dmGZn69J4oT6k2nrZZG/E3HSt9122l0Rmk0+DmWTY/Lg+v8KTUFZQ1p7d
         foisZGA5RTY5JOoPYWD35OcSQVmQ665aSG009qhRtyZWyj5e8QsGULxGyHXkNM60IrNO
         UbBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=igi2ZowC;
       spf=pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=enh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f17sor1433184ljg.16.2019.05.22.16.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 16:09:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=igi2ZowC;
       spf=pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=enh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Zo0ta7cFHgMRhNj415CGcWxBRhsPIdMQaFfQkNGZDyg=;
        b=igi2ZowCRR3eZ9/0nTV8cXZJb9K3GEJ6nM7xrdpCgyuIedU5DlpD8BYtYq2g7fhIK6
         FMPk+pIR3l66HCoBcqnR8RLDUlNVKBoDdSOOKbybJMa8cIyuAzuBD0XVwoayLR91TP1S
         Or9Vm+AM1MqvKUg9+c3gOd7GP47AnzQE07FfPqL0gIQFQsaz6/Wtl6TltaTcvzbkWmzx
         nUHyczH55lHnf4QLfD7YMKsWm2P4/KbXTCsRnYy/LgXeL0UQ2MOisKGH9I79sJSp7fTc
         mCIju+QQoBZwdM0ZHmLkXpay4k0e/6JiSlhqZI0PrF8znz18Mpt9AP9bfE2L3yEv2l8R
         69MQ==
X-Google-Smtp-Source: APXvYqyzdpKdhtViUHlA5ZulCPuE1mR7dT316mPXUNWFyB1kZFy9VtMEAzPhqeN7WBqyKU4f463JOkqzDuNZUlPEoK8=
X-Received: by 2002:a2e:885a:: with SMTP id z26mr2119940ljj.35.1558566583161;
 Wed, 22 May 2019 16:09:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp> <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp> <201905221316.865581CF@keescook> <CAFKCwrjOjdJAbcABp3qxwyYy+hgfyQirvmqGkDSJVJe5pSz0Uw@mail.gmail.com>
In-Reply-To: <CAFKCwrjOjdJAbcABp3qxwyYy+hgfyQirvmqGkDSJVJe5pSz0Uw@mail.gmail.com>
From: enh <enh@google.com>
Date: Wed, 22 May 2019 16:09:31 -0700
Message-ID: <CAJgzZorUPzrXu0ysDdKwnqdvgWZJ9tqRjF-9_5CU_UV+c0bRCA@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Evgenii Stepanov <eugenis@google.com>
Cc: Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 4:03 PM Evgenii Stepanov <eugenis@google.com> wrote:
>
> On Wed, May 22, 2019 at 1:47 PM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Wed, May 22, 2019 at 05:35:27PM +0100, Catalin Marinas wrote:
> > > The two hard requirements I have for supporting any new hardware feature
> > > in Linux are (1) a single kernel image binary continues to run on old
> > > hardware while making use of the new feature if available and (2) old
> > > user space continues to run on new hardware while new user space can
> > > take advantage of the new feature.
> >
> > Agreed! And I think the series meets these requirements, yes?
> >
> > > For MTE, we just can't enable it by default since there are applications
> > > who use the top byte of a pointer and expect it to be ignored rather
> > > than failing with a mismatched tag. Just think of a hwasan compiled
> > > binary where TBI is expected to work and you try to run it with MTE
> > > turned on.
> >
> > Ah! Okay, here's the use-case I wasn't thinking of: the concern is TBI
> > conflicting with MTE. And anything that starts using TBI suddenly can't
> > run in the future because it's being interpreted as MTE bits? (Is that
> > the ABI concern? I feel like we got into the weeds about ioctl()s and
> > one-off bugs...)
> >
> > So there needs to be some way to let the kernel know which of three
> > things it should be doing:
> > 1- leaving userspace addresses as-is (present)
> > 2- wiping the top bits before using (this series)
> > 3- wiping the top bits for most things, but retaining them for MTE as
> >    needed (the future)
> >
> > I expect MTE to be the "default" in the future. Once a system's libc has
> > grown support for it, everything will be trying to use MTE. TBI will be
> > the special case (but TBI is effectively a prerequisite).
> >
> > AFAICT, the only difference I see between 2 and 3 will be the tag handling
> > in usercopy (all other places will continue to ignore the top bits). Is
> > that accurate?
> >
> > Is "1" a per-process state we want to keep? (I assume not, but rather it
> > is available via no TBI/MTE CONFIG or a boot-time option, if at all?)
> >
> > To choose between "2" and "3", it seems we need a per-process flag to
> > opt into TBI (and out of MTE). For userspace, how would a future binary
> > choose TBI over MTE? If it's a library issue, we can't use an ELF bit,
> > since the choice may be "late" after ELF load (this implies the need
> > for a prctl().) If it's binary-only ("built with HWKASan") then an ELF
> > bit seems sufficient. And without the marking, I'd expect the kernel to
> > enforce MTE when there are high bits.
> >
> > > I would also expect the C library or dynamic loader to check for the
> > > presence of a HWCAP_MTE bit before starting to tag memory allocations,
> > > otherwise it would get SIGILL on the first MTE instruction it tries to
> > > execute.
> >
> > I've got the same question as Elliot: aren't MTE instructions just NOP
> > to older CPUs? I.e. if the CPU (or kernel) don't support it, it just
> > gets entirely ignored: checking is only needed to satisfy curiosity
> > or behavioral expectations.
>
> MTE instructions are not NOP. Most of them have side effects (changing
> register values, zeroing memory).

no, i meant "they're encoded in a space that was previously no-ops, so
running on MTE code on old hardware doesn't cause SIGILL".

> This only matters for stack tagging, though. Heap tagging is a runtime
> decision in the allocator.
>
> If an image needs to run on old hardware, it will have to do heap tagging only.
>
> > To me, the conflict seems to be using TBI in the face of expecting MTE to
> > be the default state of the future. (But the internal changes needed
> > for TBI -- this series -- is a prereq for MTE.)
> >
> > --
> > Kees Cook

