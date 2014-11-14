Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 297A96B00E6
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 21:01:42 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so16589708pab.38
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 18:01:41 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id sv10si15426080pab.161.2014.11.13.18.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 18:01:40 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 14 Nov 2014 10:01:34 +0800
Subject: RE: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
In-Reply-To: <20141113235322.GC4042@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> -----Original Message-----
> From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> Sent: Friday, November 14, 2014 7:53 AM
> To: Wang, Yalin
> > On Fri, Oct 31, 2014 at 01:42:44PM +0800, Wang, Yalin wrote:
> > This patch add bitrev.h file to support rbit instruction, so that we
> > can do bitrev operation by hardware.
> > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > ---
> >  arch/arm/Kconfig              |  1 +
> >  arch/arm/include/asm/bitrev.h | 21 +++++++++++++++++++++
> >  2 files changed, 22 insertions(+)
> >  create mode 100644 arch/arm/include/asm/bitrev.h
> >
> > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig index
> > 89c4b5c..be92b3b 100644
> > --- a/arch/arm/Kconfig
> > +++ b/arch/arm/Kconfig
> > @@ -28,6 +28,7 @@ config ARM
> >  	select HANDLE_DOMAIN_IRQ
> >  	select HARDIRQS_SW_RESEND
> >  	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
> > +	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
>=20
> Looking at this, this is just wrong.  Take a moment to consider what
> happens if we build a kernel which supports both ARMv6 _and_ ARMv7 CPUs.
> What happens if an ARMv6 CPU tries to execute an rbit instruction?

Is it possible to build a kernel that support both CPU_V6 and CPU_V7?
I mean in Kconfig, CPU_V6 =3D y and CPU_V7 =3D y ?
If there is problem like you said,
How about this solution:
select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6) =20


> Second point (which isn't obvious from your submissions on-list) is that
> you've loaded the patch system up with patches for other parts of the
> kernel tree for which I am not responsible for.  As such, I can't take
> those patches without the sub-tree maintainer acking them.  Also, the
> commit text in those patches look weird:
>=20
> 6fire: Convert byte_rev_table uses to bitrev8
>=20
> Use the inline function instead of directly indexing the array.
>=20
> This allows some architectures with hardware instructions for bit reversa=
ls
> to eliminate the array.
>=20
> Signed-off-by: Joe Perches <(address hidden)>
> Signed-off-by: Yalin Wang <(address hidden)>
>=20
> Why is Joe signing off on these patches?  As his is the first sign-off, o=
ne
> assumes that he was responsible for creating the patch in the first place=
,
> but there is no From: line marking him as the author.  Shouldn't his entr=
y
> be an Acked-by: ?
>=20
> Confused.
For this patch,
I just cherry-pick from Joe,
If you are not responsible for this part,
I will submit to the maintainers for these patches .
Sorry for that .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
