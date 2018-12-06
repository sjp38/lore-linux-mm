Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29FD16B79F9
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:25:02 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id q7so82344wrw.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:25:02 -0800 (PST)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70087.outbound.protection.outlook.com. [40.107.7.87])
        by mx.google.com with ESMTPS id h15si170628wri.367.2018.12.06.04.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 04:25:01 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V4 2/6] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Date: Thu, 6 Dec 2018 12:24:59 +0000
Message-ID: <20181206122448.GA17473@capper-debian.cambridge.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-3-steve.capper@arm.com>
 <20181205173651.GD27881@arrakis.emea.arm.com>
In-Reply-To: <20181205173651.GD27881@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7E51D42D4238694986685EBA40B3C292@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Wed, Dec 05, 2018 at 05:36:52PM +0000, Catalin Marinas wrote:
> On Wed, Dec 05, 2018 at 04:41:41PM +0000, Steve Capper wrote:
> > We wish to introduce a 52-bit virtual address space for userspace but
> > maintain compatibility with software that assumes the maximum VA space
> > size is 48 bit.
> >=20
> > In order to achieve this, on 52-bit VA systems, we make mmap behave as
> > if it were running on a 48-bit VA system (unless userspace explicitly
> > requests a VA where addr[51:48] !=3D 0).
> >=20
> > On a system running a 52-bit userspace we need TASK_SIZE to represent
> > the 52-bit limit as it is used in various places to distinguish between
> > kernelspace and userspace addresses.
> >=20
> > Thus we need a new limit for mmap, stack, ELF loader and EFI (which use=
s
> > TTBR0) to represent the non-extended VA space.
> >=20
> > This patch introduces DEFAULT_MAP_WINDOW and DEFAULT_MAP_WINDOW_64 and
> > switches the appropriate logic to use that instead of TASK_SIZE.
> >=20
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks!
