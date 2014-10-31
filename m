Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1D01F280018
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 22:03:35 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so6297686pdi.2
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 19:03:34 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id qk1si7970588pac.189.2014.10.30.19.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 19:03:34 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 31 Oct 2014 10:03:27 +0800
Subject: RE: [RFC V5 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1826F@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
In-Reply-To: <20141030120127.GC32589@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>
Cc: 'Rob Herring' <robherring2@gmail.com>, 'Joe Perches' <joe@perches.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> From: Will Deacon [mailto:will.deacon@arm.com]
> Sent: Thursday, October 30, 2014 8:01 PM
> To: Wang, Yalin
> Cc: 'Rob Herring'; 'Joe Perches'; 'Russell King - ARM Linux'; 'linux-
> kernel@vger.kernel.org'; 'akinobu.mita@gmail.com'; 'linux-mm@kvack.org';
> 'linux-arm-kernel@lists.infradead.org'
> Subject: Re: [RFC V5 3/3] arm64:add bitrev.h file to support rbit
> instruction
>=20
> > +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
> > +{
> > +	if (__builtin_constant_p(x)) {
> > +		x =3D (x >> 16) | (x << 16);
> > +		x =3D ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
> > +		x =3D ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
> > +		x =3D ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
> > +		return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);
>=20
> Shouldn't this part be in the generic code?

Good  idea, I will change this part into linux/bitrev.h .
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
