Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 797136B401E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:11:55 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 66-v6so22646759itz.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:11:55 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50087.outbound.protection.outlook.com. [40.107.5.87])
        by mx.google.com with ESMTPS id u7si85519iom.121.2018.11.26.04.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Nov 2018 04:11:54 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 5/5] arm64: mm: Allow forcing all userspace addresses
 to 52-bit
Date: Mon, 26 Nov 2018 12:11:52 +0000
Message-ID: <20181126121141.GB2012@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-6-steve.capper@arm.com>
 <20181123182233.GL3360@arrakis.emea.arm.com>
In-Reply-To: <20181123182233.GL3360@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D638D05AA6AD6A419BDF928E3383B2ED@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Fri, Nov 23, 2018 at 06:22:34PM +0000, Catalin Marinas wrote:
> On Wed, Nov 14, 2018 at 01:39:20PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index eab02d24f5d1..17d363e40c4d 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -1165,6 +1165,20 @@ config ARM64_CNP
> >  	  at runtime, and does not affect PEs that do not implement
> >  	  this feature.
> > =20
> > +config ARM64_FORCE_52BIT
> > +	bool "Force 52-bit virtual addresses for userspace"
> > +	default n
>=20
> No need for "default n"
>=20
> > +	depends on ARM64_52BIT_VA && EXPERT
>=20
> As long as it's for debug only and depends on EXPERT, it's fine by me.

Okay, I'll remove this default n.

Cheers,
--=20
Steve
