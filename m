Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id AAE526B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 21:06:02 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id a141so18735543oig.3
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 18:06:02 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id ks8si328730oeb.66.2015.01.11.18.05.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 18:06:01 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 12 Jan 2015 10:05:30 +0800
Subject: FW: [RFC V6 2/3 resend] arm:add bitrev.h file to support rbit
 instruction   
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E19A@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> -----Original Message-----
> From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> Sent: Friday, January 09, 2015 7:11 PM
> To: Wang, Yalin
> Cc: 'Ard Biesheuvel'; 'Will Deacon'; 'linux-kernel@vger.kernel.org';=20
> 'akinobu.mita@gmail.com'; 'linux-mm@kvack.org'; 'Joe Perches';=20
> 'linux-arm- kernel@lists.infradead.org'
> Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit=20
> instruction
>=20
> On Fri, Jan 09, 2015 at 10:16:32AM +0800, Wang, Yalin wrote:
> > > -----Original Message-----
> > > From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> > > Sent: Friday, January 09, 2015 2:41 AM
> > > To: Wang, Yalin
> > > Cc: 'Will Deacon'; 'Ard Biesheuvel';=20
> > > 'linux-kernel@vger.kernel.org'; 'akinobu.mita@gmail.com';=20
> > > 'linux-mm@kvack.org'; 'Joe Perches';
> > > 'linux-arm- kernel@lists.infradead.org'
> > > Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit=20
> > > instruction
> > >
> > > The root cause is that the kernel being built is supposed to=20
> > > support both
> > > ARMv7 and ARMv6K CPUs.  However, "rbit" is only available on
> > > ARMv6T2 (thumb2) and ARMv7, and not plain ARMv6 or ARMv6K CPUs.
> > >
> > In the patch that you applied:
> > 8205/1 	add bitrev.h file to support rbit instruction
> >
> > I have add :
> > +	select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6)
> >
> > If you build kernel support ARMv6K, should CONFIG_CPU_V6=3Dy, isn't it =
?
> > Then will not build hardware rbit instruction, isn't it ?
>=20
> The config has:
>=20
> CONFIG_CPU_PJ4=3Dy
> # CONFIG_CPU_V6 is not set
> CONFIG_CPU_V6K=3Dy
> CONFIG_CPU_V7=3Dy
> CONFIG_CPU_32v6=3Dy
> CONFIG_CPU_32v6K=3Dy
> CONFIG_CPU_32v7=3Dy
>=20
> And no, the CONFIG_CPU_V* flags refer to the CPUs.  The
> CONFIG_CPU_32v* symbols refer to the CPU architectures.
>=20
Oh, I see,
How about change like this:
+	select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6 &&=20
+!CPU_V6K)
I am not sure if I also need add some older CPU types like !CPU_ARM9TDMI &&=
=1B$B!!=1B(B!CPU_ARM940T ?

Another solution is:
+	select HAVE_ARCH_BITREVERSE if ((CPU_32V7M || CPU_32V7) && !CPU_32V6=20
+&& !CPU_32V5 && !CPU_32V4 && !CPU_32V4T && !CPU_32V3)

By the way, I am not clear about the difference between CPU_V6 and CPU_V6K,=
 could you tell me? :)

Thank you=20







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
