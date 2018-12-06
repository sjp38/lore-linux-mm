Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 300FD6B7A80
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:52:50 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y7so225896wrr.12
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:52:50 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140083.outbound.protection.outlook.com. [40.107.14.83])
        by mx.google.com with ESMTPS id u16si420371wrt.175.2018.12.06.06.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Dec 2018 06:52:47 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V4 5/6] arm64: mm: introduce 52-bit userspace support
Date: Thu, 6 Dec 2018 14:52:46 +0000
Message-ID: <20181206145236.GA408@capper-debian.cambridge.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-6-steve.capper@arm.com>
 <e1a9b147-d635-9f32-2f33-ccd689dba858@arm.com>
 <20181206122603.GB17473@capper-debian.cambridge.arm.com>
 <c87c833a-7dfc-6cd4-aad7-119df9bd7178@arm.com>
In-Reply-To: <c87c833a-7dfc-6cd4-aad7-119df9bd7178@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3970E43866B09449B2F3F19F50340B9F@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki Poulose <Suzuki.Poulose@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Thu, Dec 06, 2018 at 02:35:20PM +0000, Suzuki K Poulose wrote:
>=20
>=20
> On 06/12/2018 12:26, Steve Capper wrote:
> > On Wed, Dec 05, 2018 at 06:22:27PM +0000, Suzuki K Poulose wrote:
> > > Hi Steve,
> > >=20
> > [...]
> > > I think we may need a check for the secondary CPUs to make sure that =
they have
> > > the 52bit support once the boot CPU has decided to use the feature an=
d fail the
> > > CPU bring up (just like we do for the granule support).
> > >=20
> > > Suzuki
> >=20
> > Hi Suzuki,
> > I have just written a patch to detect a mismatch between 52-bit VA that
> > is being tested now.
> >=20
> > As 52-bit kernel VA support is coming in future, the patch checks for a
> > mismatch during the secondary boot path and, if one is found, prevents
> > the secondary from booting (and displays an error message to the user).
>=20
> Right now, it is the boot CPU which decides the Userspace 52bit VA, isn't=
 it ?
> Irrespective of the kernel VA support, the userspace must be able to run =
on
> all the CPUs on the system, right ? So don't we need it now, with this se=
ries ?

Hi Suzuki,

Yes the boot CPU determines vabits_user. My idea was to have the
secondary CPUs check to see if vabits_user was 52, and if so, then check
to see if it's capable of supporting 52-bit. If not, then it stops
booting (and sets a flag to indicate why).

This check will be valid for 52-bit userspace support and also valid for
52-bit kernel support (as the check is performed before the secondary
mmu is enabled). I didn't want to write a higher level detection
routine for the userspace support and then have to re-write it later
when introducing 52-bit kernel support.

I'm happy to do what works though, I thought this way was simplest :-).

Cheers,
--=20
Steve
