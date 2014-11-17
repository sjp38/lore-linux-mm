Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4384C6B0069
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 21:39:10 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so5168267pdj.27
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 18:39:09 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id gn9si33992153pac.127.2014.11.16.18.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 18:39:08 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 17 Nov 2014 10:38:58 +0800
Subject: RE: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313C6@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
 <20141114095812.GG4042@n2100.arm.linux.org.uk>
In-Reply-To: <20141114095812.GG4042@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> Sent: Friday, November 14, 2014 5:58 PM
> To: Wang, Yalin
> Cc: 'Will Deacon'; 'Ard Biesheuvel'; 'linux-kernel@vger.kernel.org';
> 'akinobu.mita@gmail.com'; 'linux-mm@kvack.org'; 'Joe Perches'; 'linux-arm=
-
> kernel@lists.infradead.org'
> Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instructi=
on
>
> > Is it possible to build a kernel that support both CPU_V6 and CPU_V7?
>=20
> Absolutely it is.
>=20
> > I mean in Kconfig, CPU_V6 =3D y and CPU_V7 =3D y ?
>=20
> Yes.
>=20
> > If there is problem like you said,
> > How about this solution:
> > select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6)
>=20
> That would work.
>=20
OK, I will submit a patch for this change.

> > For this patch,
> > I just cherry-pick from Joe,
> > If you are not responsible for this part, I will submit to the
> > maintainers for these patches .
> > Sorry for that .
>=20
> I think you need to discuss with Joe how Joe would like his patches handl=
ed.
> However, it seems that Joe already sent his patches to the appropriate
> maintainers, and they have been applying those patches themselves.
>=20
> Since your generic ARM changes depend on these patches being accepted fir=
st,
> this means is that I can't apply the generic ARM changes until those othe=
r
> patches have hit mainline, otherwise things are going to break.  So, when
> you come to submit the latest set of patches to the patch system, please =
do
> so only after these dependent patches have been merged into mainline so
> that they don't get accidentally applied before hand and break the two
> drivers that Joe mentioned.

Joe has submitted patches to maintainers,
So we need wait for them to be accepted .

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
