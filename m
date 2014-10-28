Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4A1900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 21:35:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so6672410pab.0
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 18:35:18 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id fo9si11737364pdb.175.2014.10.27.18.34.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 18:35:18 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 28 Oct 2014 09:34:42 +0800
Subject: RE: [RFC V3] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1825A@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18259@CNBJMBX05.corpusers.net>
 <20141027104848.GD8768@arm.com>
In-Reply-To: <20141027104848.GD8768@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>

> From: Will Deacon [mailto:will.deacon@arm.com]
> > +++ b/arch/arm/include/asm/bitrev.h
> > @@ -0,0 +1,28 @@
> > +#ifndef __ASM_ARM_BITREV_H
> > +#define __ASM_ARM_BITREV_H
> > +
> > +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
> > +{
> > +	if (__builtin_constant_p(x)) {
> > +		x =3D (x >> 16) | (x << 16);
> > +		x =3D ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
> > +		x =3D ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
> > +		x =3D ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
> > +		return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);
> > +	}
> > +	__asm__ ("rbit %0, %1" : "=3Dr" (x) : "r" (x));
>=20
> I think you need to use %w0 and %w1 here, otherwise you bit-reverse the 6=
4-
> bit register.
For arm64 in arch/arm64/include/asm/bitrev.h.
I have use __asm__ ("rbit %w0, %w1" : "=3Dr" (x) : "r" (x));
For arm , I use __asm__ ("rbit %0, %1" : "=3Dr" (x) : "r" (x));
Am I right ?
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
