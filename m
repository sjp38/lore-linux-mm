Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03364C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2ACC21773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:00:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2ACC21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29D886B0281; Thu, 23 May 2019 13:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24E116B0282; Thu, 23 May 2019 13:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 115526B0288; Thu, 23 May 2019 13:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2B16B0281
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:00:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h12so9851354edl.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:00:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lz64bYSPlrFtj6eVpp0c1OtriSm5u7hDnDI/lxC1vdU=;
        b=Ma6kmHpNgBZZkzV3ZFsbpGXVLil0mt0nxo+b1Ix85HoP4I3dxj/rU+uppJ4VQvfWBI
         pfNpif2lKvlh0Bh+ta2Xn8IaDdHqK0W2QU6LgACIkBAo/vw1jv/2L3DIbkcgxaXV0HtK
         2PiYWMiRn7bNMgP+eIxuRfbCL6bKiKoqZrqYrPzSRnBM5cQtYWOHu5o4dVsHjav3FFVU
         Gj97nBTfccn8Uyj8VF3oAmgTEl2PXLh2kyjkLpNsV1VFjoNizEy4cA77oMJkRkLvr9Cy
         T+fgkw4vjqXxn/xB0DVQgES+E1cOCkEPApoQbsjJ7q7dGgXv4is6rXDi4dk4/B+ItJWZ
         82VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV2YTyVhOLsg7pQuXs99GVvqQrbTI4J0GOSiFOZcZ/tgkLrXov2
	d+6NGr9A4k3Ax8qNKYLB0L5p+keVUPpo0+69GhaQlSOwLdX1PctPvCWIuk1KCYHit6gdozkdvRo
	daulEogOs8nTc9QOsUbGmeWuusqEyjeDCTFQ6muPg8uAW/IKr7v7MMLeT/6sv0mKXOA==
X-Received: by 2002:a50:fa90:: with SMTP id w16mr98865428edr.184.1558630838337;
        Thu, 23 May 2019 10:00:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyc/x5IZ2y4qyC3Y03ZIFUdn+YR32Fjm6cp/l83UdCgwdTWCAD0Nd1TxGFxyH3rRCxDDrx
X-Received: by 2002:a50:fa90:: with SMTP id w16mr98865315edr.184.1558630837534;
        Thu, 23 May 2019 10:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558630837; cv=none;
        d=google.com; s=arc-20160816;
        b=foK1Y6BI/SNG1G2bk+uduN9o01mUUFtQ7jo47WisSXA2ysyxrTpZ8fUTkJlj0f/GLM
         DGMg4BY4YFtbpLoGl9K63FhtOrK1uvaUdtndLlA6kZTwBsZxt30lwzSyX55JZLkI5Zzl
         g726ljLbtWVcaB3zBeMrnqQjIXQcleLXk3UwRZEQ9BbvPH5wABHumNEpfHt5uimUZOZI
         kFLfSoNIhxkYf8jWuGQJgcB356TPDVC5vnBTOeBkoSHZigGB6JVcFwE+mOqsG7FXhNQu
         2scZkJrj3McD8DUlB9Cz+TeW3QEVhZod7Q4TZcT55oIm7g/Qr+6AG2lRz0knTv+X1PHO
         Zfpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lz64bYSPlrFtj6eVpp0c1OtriSm5u7hDnDI/lxC1vdU=;
        b=OBIofu1wo/jqwJvsAdqn4fBvBfUuNJppoLyWdOkzE94RvP+oElUb2tCCsBJ6BIBqyq
         4hGfzRzTB0QwLDgtmg8LDVPglArODiwVTeX7TFHh6h9DhYzWdRc5YtdF0Kj0ncJVp4BW
         UeVviCwYTs6KDtBJuv/7SSvbEVY4YGz4zYYKPZYaNMOeYINi0+2UMtRNbEnhXnDxO0bA
         QkP0abDMhTBRxgNRlYiyaacOdhQI+X+15NDHNzaObGljOy3q85+w1fHC4qVCEy39ZgIg
         OeF0FWu9YurO1JVWCGU7Z9/ZssyTvjKSOJSuqwdvrPXZbblRMOZx6beXOIgmMqZ7PGQ2
         Cgtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q4si8269743edb.361.2019.05.23.10.00.37
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 10:00:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3B21C374;
	Thu, 23 May 2019 10:00:36 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DF1633F5AF;
	Thu, 23 May 2019 10:00:29 -0700 (PDT)
Date: Thu, 23 May 2019 18:00:27 +0100
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
Message-ID: <20190523170026.nso2me5qnrrjbrdr@mbp>
References: <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <CAJgzZoqX--Kd9=Kjpnfz-5cjVJ=TdsXM5dJM_EjLFKniVbny2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJgzZoqX--Kd9=Kjpnfz-5cjVJ=TdsXM5dJM_EjLFKniVbny2w@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 08:44:12AM -0700, enh wrote:
> On Thu, May 23, 2019 at 7:45 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Wed, May 22, 2019 at 01:47:36PM -0700, Kees Cook wrote:
> > > For userspace, how would a future binary choose TBI over MTE? If it's
> > > a library issue, we can't use an ELF bit, since the choice may be
> > > "late" after ELF load (this implies the need for a prctl().) If it's
> > > binary-only ("built with HWKASan") then an ELF bit seems sufficient.
> > > And without the marking, I'd expect the kernel to enforce MTE when
> > > there are high bits.
> >
> > The current plan is that a future binary issues a prctl(), after
> > checking the HWCAP_MTE bit (as I replied to Elliot, the MTE instructions
> > are not in the current NOP space). I'd expect this to be done by the
> > libc or dynamic loader under the assumption that the binaries it loads
> > do _not_ use the top pointer byte for anything else.
> 
> yeah, it sounds like to support hwasan and MTE, the dynamic linker
> will need to not use either itself.
> 
> > With hwasan compiled objects this gets more confusing (any ELF note
> > to identify them?).
> 
> no, at the moment code that wants to know checks for the presence of
> __hwasan_init. (and bionic doesn't actually look at any ELF notes
> right now.) but we can always add something if we need to.

It's a userspace decision to make. In the kernel, we are proposing that
bionic calls a prctl() to enable MTE explicitly. It could first check
for the presence of __hwasan_init.

-- 
Catalin

