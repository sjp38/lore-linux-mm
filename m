Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39935C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C63952173C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Dx4+lU9j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C63952173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3892A6B0003; Mon, 20 May 2019 19:53:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35FCC6B0005; Mon, 20 May 2019 19:53:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24EB16B0006; Mon, 20 May 2019 19:53:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03CA26B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:53:21 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id 76so2446641uat.12
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DOow0La3W2Essx5H031uTOWFbAnDcBGJlXVfamcoL3w=;
        b=OBpL1rTqhAOMMsDuoQHu6shgD3n7pVSDxy616YsmYa96iUEIlLW5ETTSeEZaDm+5pv
         08YTaQy8zGF/pEWq3acVWW9zrzi1Xnv4edsmk5E/QQ1OrMpcaymWq1Qxwj9E799F71Pr
         QFKpbDhAO83acnJsQPiL8Ex/RJOQpEp06Ia4U511e70FQyUtGz+YIo8NR0Lc0wd5TyzL
         hl6AqY17puKWVsGL4uFZEYn8XWhg4nM3g/xOEY/rQKdKVHcp2zpt6kc0EHbjfvM3Z/Os
         4ChWfmDkgns5wXTMn0KWLGbr4eCu/yDLo3onPZmgDycZt/5yKXfXnYcT99qcJ+8bksLR
         MkBw==
X-Gm-Message-State: APjAAAXiFiOJyrjizcyQhBkUDFo4Z5smPtTljQ/DK3o0i8roUHPaO6dQ
	ih6XfeLzx89Qu3U05oewyy+wD2gN1HODyhrq4xYwFU1MCaboyqIUFIJ5DUwvuX91cJj28y0o9EW
	cQlhRLcIDSbHEYQ8wjivwoCQ0Dz7RhLau9ult50qUjPZiJgQhWkHhmgVM/8pN30svjg==
X-Received: by 2002:a67:e98e:: with SMTP id b14mr33306039vso.145.1558396400630;
        Mon, 20 May 2019 16:53:20 -0700 (PDT)
X-Received: by 2002:a67:e98e:: with SMTP id b14mr33306016vso.145.1558396399696;
        Mon, 20 May 2019 16:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558396399; cv=none;
        d=google.com; s=arc-20160816;
        b=j5qa2BOtuM2Jh3vBcoAQoaOATxhLS7aukTcKs6iF8zZcSmKFU5nDeNHGtHzuAsQgYO
         2SYTES5IYlv9idBNLxTasDc2z7xjDJCe8bwMs88Nm6BLDir2zDkaG3PA/ArBWnDxb+UX
         e7+mytfT9ZK+w2OSzfXEs9obCCnHVZRW5xa3IbJ8HSppIEXaEVyEonm8xUa/O5lEB4FR
         jvXIEu/IemcW6bUtKyVmKLpwSIzgJ6m1koAlUe5DiomR2Re72zL4GymH5nBj4QEttvQh
         Q811bsvW3FS7C8xkY/YA3RXS66s0ibExgV9/HSUvJL/M8+wicWKUm7B+zs8bJK6Jcwqc
         I35g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DOow0La3W2Essx5H031uTOWFbAnDcBGJlXVfamcoL3w=;
        b=FuBhcote1Dw5ytgOrzQf3g6RTffNYx696zCXo+8iNiPjEBZlRI8LajXohluFCyEffB
         Yt0EOOED93tGwNQKVhlr4JbRd89JMSIzijonFtB+oKwGDjSVoobEpdR4RaVs76QN3Oln
         wfhvEyVe2dL7/MBJGB+VMoIiJh8mEamgDFIvHQvepnb5mcNCJnhr3afeSK3Dxj7LDASV
         7Arg51ChhXwaZP8G1JN/v4kie/+GAfoxkBmu59pIUlNqAzfKcoKYMrnmsbyjLHZQUDH4
         v7vsPJYDcrX/ahSLfV3WyDlWlgp9ImKEkgsKQwAXWylmsKn4jCeA/UfKwGvJkN4iQyKr
         JKNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Dx4+lU9j;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor8474481vsn.9.2019.05.20.16.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 16:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Dx4+lU9j;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DOow0La3W2Essx5H031uTOWFbAnDcBGJlXVfamcoL3w=;
        b=Dx4+lU9jqXDtln/17Mrd8EV4Dxp/5zASL+1Y8Niio9Pqb06rC0aI8wedP3ohgziyEW
         jppEZzDyXiAo/njLuzUnS0cZqB4tlCDf5SInO7A6W3spDccr9FtwpNa39rs9vTjn9Pol
         gFjx66w14oqATAsCg/4xevDnAIAQo2Q0YzZMa3Njt5yFKOelm+SuxVUsWhk4woonxC/+
         9D5FC/UAWBXCau72ARfrLZBFx2zGvzGs/3QYXrUb8NFYR9FnDOYRxbwkdocqirkPGsSw
         AxoIYh3MeUP070fRiIy388VcetefsVsnX0FjFahzGTgGe2zBg5LkCE8dqpCaiB/D65kK
         79Pw==
X-Google-Smtp-Source: APXvYqyR0JsazypV3hCmWgdEzYpNKlJ3PjKF8ENA0Fjbz+eEGES/3XAyQs/kAm4YlbOIpNAtAAzvW9GW3+g1GtceCfY=
X-Received: by 2002:a67:be17:: with SMTP id x23mr26047761vsq.173.1558396399029;
 Mon, 20 May 2019 16:53:19 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <20190517144931.GA56186@arrakis.emea.arm.com>
In-Reply-To: <20190517144931.GA56186@arrakis.emea.arm.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 20 May 2019 16:53:07 -0700
Message-ID: <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Elliott Hughes <enh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 7:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Hi Andrey,
>
> On Mon, May 06, 2019 at 06:30:46PM +0200, Andrey Konovalov wrote:
> > One of the alternative approaches to untagging that was considered is to
> > completely strip the pointer tag as the pointer enters the kernel with
> > some kind of a syscall wrapper, but that won't work with the countless
> > number of different ioctl calls. With this approach we would need a custom
> > wrapper for each ioctl variation, which doesn't seem practical.
>
> The more I look at this problem, the less convinced I am that we can
> solve it in a way that results in a stable ABI covering ioctls(). While
> for the Android kernel codebase it could be simpler as you don't upgrade
> the kernel version every 2.5 months, for the mainline kernel this
> doesn't scale. Any run-time checks are relatively limited in terms of
> drivers covered. Better static checking would be nice as a long term
> solution but we didn't get anywhere with the discussion last year.
>
> IMO (RFC for now), I see two ways forward:
>
> 1. Make this a user space problem and do not allow tagged pointers into
>    the syscall ABI. A libc wrapper would have to convert structures,
>    parameters before passing them into the kernel. Note that we can
>    still support the hardware MTE in the kernel by enabling tagged
>    memory ranges, saving/restoring tags etc. but not allowing tagged
>    addresses at the syscall boundary.
>
> 2. Similar shim to the above libc wrapper but inside the kernel
>    (arch/arm64 only; most pointer arguments could be covered with an
>    __SC_CAST similar to the s390 one). There are two differences from
>    what we've discussed in the past:
>
>    a) this is an opt-in by the user which would have to explicitly call
>       prctl(). If it returns -ENOTSUPP etc., the user won't be allowed
>       to pass tagged pointers to the kernel. This would probably be the
>       responsibility of the C lib to make sure it doesn't tag heap
>       allocations. If the user did not opt-in, the syscalls are routed
>       through the normal path (no untagging address shim).
>
>    b) ioctl() and other blacklisted syscalls (prctl) will not accept
>       tagged pointers (to be documented in Vicenzo's ABI patches).
>
> It doesn't solve the problems we are trying to address but 2.a saves us
> from blindly relaxing the ABI without knowing how to easily assess new
> code being merged (over 500K lines between kernel versions). Existing
> applications (who don't opt-in) won't inadvertently start using the new
> ABI which could risk becoming de-facto ABI that we need to support on
> the long run.
>
> Option 1 wouldn't solve the ioctl() problem either and while it makes
> things simpler for the kernel, I am aware that it's slightly more
> complicated in user space (but I really don't mind if you prefer option
> 1 ;)).
>
> The tagged pointers (whether hwasan or MTE) should ideally be a
> transparent feature for the application writer but I don't think we can
> solve it entirely and make it seamless for the multitude of ioctls().
> I'd say you only opt in to such feature if you know what you are doing
> and the user code takes care of specific cases like ioctl(), hence the
> prctl() proposal even for the hwasan.
>
> Comments welcomed.

Any userspace shim approach is problematic for Android because of the
apps that use raw system calls. AFAIK, all apps written in Go are in
that camp - I'm not sure how common they are, but getting them all
recompiled is probably not realistic.

The way I see it, a patch that breaks handling of tagged pointers is
not that different from, say, a patch that adds a wild pointer
dereference. Both are bugs; the difference is that (a) the former
breaks a relatively uncommon target and (b) it's arguably an easier
mistake to make. If MTE adoption goes well, (a) will not be the case
for long.

This is a bit of a chicken-and-egg problem. In a world where memory
allocators on one or several popular platforms generate pointers with
non-zero tags, any such breakage will be caught in testing.
Unfortunately to reach that state we need the kernel to start
accepting tagged pointers first, and then hold on for a couple of
years until userspace catches up.

Perhaps we can start by whitelisting ioctls by driver?

