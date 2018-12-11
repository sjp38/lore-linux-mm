Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDA58E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:14:03 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id v8so13731630ioq.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:14:03 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50066.outbound.protection.outlook.com. [40.107.5.66])
        by mx.google.com with ESMTPS id 13si7645999jat.33.2018.12.11.01.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 01:14:02 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V5 0/7] 52-bit userspace VAs
Date: Tue, 11 Dec 2018 09:13:59 +0000
Message-ID: <20181211091349.GA24521@capper-debian.cambridge.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181210193445.GB8923@edgewater-inn.cambridge.arm.com>
In-Reply-To: <20181210193445.GB8923@edgewater-inn.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B1DFFA7C8DC6A445852BDC2FCC2C7BAA@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <Will.Deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, nd <nd@arm.com>

Hi Will,

On Mon, Dec 10, 2018 at 07:34:46PM +0000, Will Deacon wrote:
> On Thu, Dec 06, 2018 at 10:50:35PM +0000, Steve Capper wrote:
> > This patch series brings support for 52-bit userspace VAs to systems th=
at
> > have ARMv8.2-LVA and are running with a 48-bit VA_BITS and a 64KB
> > PAGE_SIZE.
> >=20
> > If no hardware support is present, the kernel runs with a 48-bit VA spa=
ce
> > for userspace.
> >=20
> > Userspace can exploit this feature by providing an address hint to mmap
> > where addr[51:48] !=3D 0. Otherwise all the VA mappings will behave in =
the
> > same way as a 48-bit VA system (this is to maintain compatibility with
> > software that assumes the maximum VA size on arm64 is 48-bit).
> >=20
> > This patch series applies to 4.20-rc1.
> >=20
> > Testing was in a model with Trusted Firmware and UEFI for boot.
> >=20
> > Changed in V5, ttbr1 offsetting code simplified. Extra patch added to
> > check for VA space support mismatch between CPUs.
>=20
> I was all ready to push this out, but I spotted a build failure with
> allmodconfig because TASK_SIZE refers to the non-EXPORTed symbol
> vabits_user:
>=20
> ERROR: "vabits_user" [lib/test_user_copy.ko] undefined!
> ERROR: "vabits_user" [drivers/misc/lkdtm/lkdtm.ko] undefined!
> ERROR: "vabits_user" [drivers/infiniband/hw/mlx5/mlx5_ib.ko] undefined!

Apologies for that, I'll be more careful with modules in future.

>=20
> So I've pushed an extra patch on top to fix that by exporting the symbol.
>=20

Thanks!

Cheers,
--=20
Steve
