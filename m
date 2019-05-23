Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B01FC04AAC
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 07:34:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18236204EC
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 07:34:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18236204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8A786B0006; Thu, 23 May 2019 03:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A60F56B0007; Thu, 23 May 2019 03:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9501B6B000A; Thu, 23 May 2019 03:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48B336B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 03:34:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x16so7659135edm.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 00:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IVl4LltDxPODbndeBL2zCf1BFEvRQB4sJ5VTDw4EkxQ=;
        b=J/0tHFbZsU+QLDyjP7KjClbWLKHNBTIMu0a4pkU55lE0fyvufIiRq9DnYaNNVsP0Zc
         3Upp5GLpiqvOnhpukXqM3Ht2/rgCiHsv8y+L8pxmODh5KPd42KUpmmcmRwVycCS8nk2P
         BtFHpfLQQIwZ14AS5DRM4rVBJlDDQyIQdziSiL4/m/OtKhvWqiBEn2INYWs7O8tvZX/B
         bqqDho9h+OOMMwiC72ODTssqYMyOMn/TQtyMX2uE0nYYBDGiv5hkUP+9y+AW6HyUeNvM
         0FLweJ4U6GwrkskPl1MLJdAMF9UtysNHWCiRADfKboHN3iUmp1jTwiSL4SgaICbqW4PT
         6tJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWeBV9YRSU3ZBx/nHu0+/ybZfhC+6anSI8jXGOTiPoyyngHRdfF
	Mr3GJyj743IrYj7bToouICIIH3gHpJduWxGDyS0cMUgMJRIlDMO4axH+QwOpY74fMBpbp0sd7cj
	MjaRSeZdxQVeX8bcOyKQr4kNaVXBH1F1cPisxKEt+nxDpkqRdzEGP21yuFSISojRy8g==
X-Received: by 2002:a17:906:66c9:: with SMTP id k9mr26660917ejp.21.1558596877834;
        Thu, 23 May 2019 00:34:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5e/gYvlKqsQyI9riINBiSfeNVtzH/kWghS5ojlhh2GvQKK8vsiSt6wKxjss3VPu61k078
X-Received: by 2002:a17:906:66c9:: with SMTP id k9mr26660863ejp.21.1558596876868;
        Thu, 23 May 2019 00:34:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558596876; cv=none;
        d=google.com; s=arc-20160816;
        b=gPDECRremHnUIaSZvUWTPddp5YqV1Sum47HT20VZYEr3tSTX2V/s2Nhz60sFxEgsD1
         srK4jEdfQ9JKGGaqZdD5T3hegNgOvA8lVz/17sHV/IY98Ew1qxdfBfCjYpU/3kGocNeU
         9Mz493B0ub7/D4AFHe2krXyquBR1u/kzrd+zPBG0CyIePIJwtZyOP0nwHw0CgVcyG5K0
         iauSkm4BI7psrzc13CvVyf6nf2yq+MAn4xyb5DKwlulUMtClqfWQvD7cftrFC4/KaOQe
         oU5htMTXneAYKXJ5jE3sWsiOXVSSy3yf0zkQrd9IJx0Q8aWiQtM4+I1zm1JBzwYgj/7o
         33+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IVl4LltDxPODbndeBL2zCf1BFEvRQB4sJ5VTDw4EkxQ=;
        b=Rf4OTindUzHzxgPrYFt1Z5vcgxqTJ8LuZXGTGH6IIzkL/WWznzLDZGUfMV3qjzhxlc
         SHg/gmYPkAuZzjKwBKU3UPAHV3Oh36rptFv0I+8NcoPMEx1X9gUhvCP4JOLwQrzBQDSk
         4UXh38/TFvfpudSshgar1sL82QMCEsD1vVv2iRPlzu+mpaaScroCZGHQFWxtGVDg/mh3
         jqw2tf2hbbP0aV11aCjHEc7h+wfUi8D4xIWqjr8W9WOPTgJ1OoZPnlgc05eF5G6wSEKP
         ZFCIF8c/0XmPKI12RtCeWwMH0Tl1BupP1uaCR0PoG0oSeGIxPnVaKGIk/V2mIbfig2x6
         qG1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z35si4988846edb.186.2019.05.23.00.34.35
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 00:34:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AF17480D;
	Thu, 23 May 2019 00:34:34 -0700 (PDT)
Received: from MBP.local (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 89C463F575;
	Thu, 23 May 2019 00:34:28 -0700 (PDT)
Date: Thu, 23 May 2019 08:34:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: enh <enh@google.com>
Cc: Evgenii Stepanov <eugenis@google.com>,
	Kees Cook <keescook@chromium.org>,
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
Message-ID: <20190523073425.GA43379@MBP.local>
References: <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <CAFKCwrjOjdJAbcABp3qxwyYy+hgfyQirvmqGkDSJVJe5pSz0Uw@mail.gmail.com>
 <CAJgzZorUPzrXu0ysDdKwnqdvgWZJ9tqRjF-9_5CU_UV+c0bRCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJgzZorUPzrXu0ysDdKwnqdvgWZJ9tqRjF-9_5CU_UV+c0bRCA@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 04:09:31PM -0700, enh wrote:
> On Wed, May 22, 2019 at 4:03 PM Evgenii Stepanov <eugenis@google.com> wrote:
> > On Wed, May 22, 2019 at 1:47 PM Kees Cook <keescook@chromium.org> wrote:
> > > On Wed, May 22, 2019 at 05:35:27PM +0100, Catalin Marinas wrote:
> > > > I would also expect the C library or dynamic loader to check for the
> > > > presence of a HWCAP_MTE bit before starting to tag memory allocations,
> > > > otherwise it would get SIGILL on the first MTE instruction it tries to
> > > > execute.
> > >
> > > I've got the same question as Elliot: aren't MTE instructions just NOP
> > > to older CPUs? I.e. if the CPU (or kernel) don't support it, it just
> > > gets entirely ignored: checking is only needed to satisfy curiosity
> > > or behavioral expectations.
> >
> > MTE instructions are not NOP. Most of them have side effects (changing
> > register values, zeroing memory).
> 
> no, i meant "they're encoded in a space that was previously no-ops, so
> running on MTE code on old hardware doesn't cause SIGILL".

It does result in SIGILL, there wasn't enough encoding left in the NOP
space for old/current CPU implementations (in hindsight, we should have
reserved a bigger NOP space).

As Evgenii said, the libc needs to be careful when tagging the heap as
it would cause a SIGILL if the HWCAP_MTE is not set. The standard
application doesn't need to be recompiled as it would not issue MTE
colouring instructions, just standard LDR/STR.

Stack tagging is problematic if you want to colour each frame
individually, the function prologue would need the non-NOP MTE
instructions. The best we can do here is just having the (thread) stacks
of different colours.

-- 
Catalin

