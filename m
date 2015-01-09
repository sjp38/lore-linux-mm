Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id EA22A6B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 21:17:13 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id rl12so12812670iec.12
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 18:17:13 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id it7si5720097icc.75.2015.01.08.18.17.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 18:17:12 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 9 Jan 2015 10:16:32 +0800
Subject: RE: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E195@CNBJMBX05.corpusers.net>
References: <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
 <20141114095812.GG4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E688B313C6@CNBJMBX05.corpusers.net>
 <20150108184059.GZ12302@n2100.arm.linux.org.uk>
In-Reply-To: <20150108184059.GZ12302@n2100.arm.linux.org.uk>
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
> Sent: Friday, January 09, 2015 2:41 AM
> To: Wang, Yalin
> Cc: 'Will Deacon'; 'Ard Biesheuvel'; 'linux-kernel@vger.kernel.org';
> 'akinobu.mita@gmail.com'; 'linux-mm@kvack.org'; 'Joe Perches'; 'linux-arm=
-
> kernel@lists.infradead.org'
> Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instructi=
on
>=20
> On Mon, Nov 17, 2014 at 10:38:58AM +0800, Wang, Yalin wrote:
> > Joe has submitted patches to maintainers, So we need wait for them to
> > be accepted .
>=20
> I ran these patches through my autobuilder, and while most builds didn't
> seem to be a problem, the randconfigs found errors:
>=20
> /tmp/ccbiuDjS.s:137: Error: selected processor does not support ARM mode
> `rbit r3,r2'
> /tmp/ccbiuDjS.s:145: Error: selected processor does not support ARM mode
> `rbit r0,r1'
> make[4]: *** [drivers/iio/amplifiers/ad8366.o] Error 1
>=20
> /tmp/ccFhnoO3.s:6789: Error: selected processor does not support ARM mode
> `rbit r2,r2'
> make[4]: *** [drivers/mtd/devices/docg3.o] Error 1
>=20
> /tmp/cckMf2pp.s:239: Error: selected processor does not support ARM mode
> `rbit ip,ip'
> /tmp/cckMf2pp.s:241: Error: selected processor does not support ARM mode
> `rbit r2,r2'
> /tmp/cckMf2pp.s:248: Error: selected processor does not support ARM mode
> `rbit lr,lr'
> /tmp/cckMf2pp.s:250: Error: selected processor does not support ARM mode
> `rbit r3,r3'
> make[5]: *** [drivers/video/fbdev/nvidia/nvidia.o] Error 1
>=20
> /tmp/ccTgULsO.s:1151: Error: selected processor does not support ARM mode
> `rbit r1,r1'
> /tmp/ccTgULsO.s:1158: Error: selected processor does not support ARM mode
> `rbit r0,r0'
> /tmp/ccTgULsO.s:1164: Error: selected processor does not support ARM mode
> `rbit ip,ip'
> /tmp/ccTgULsO.s:1166: Error: selected processor does not support ARM mode
> `rbit r3,r3'
> /tmp/ccTgULsO.s:1227: Error: selected processor does not support ARM mode
> `rbit r5,r5'
> /tmp/ccTgULsO.s:1229: Error: selected processor does not support ARM mode
> `rbit lr,lr'
> /tmp/ccTgULsO.s:1236: Error: selected processor does not support ARM mode
> `rbit r0,r0'
> /tmp/ccTgULsO.s:1238: Error: selected processor does not support ARM mode
> `rbit r3,r3'
> make[5]: *** [drivers/video/fbdev/nvidia/nv_accel.o] Error 1
>=20
> The root cause is that the kernel being built is supposed to support both
> ARMv7 and ARMv6K CPUs.  However, "rbit" is only available on
> ARMv6T2 (thumb2) and ARMv7, and not plain ARMv6 or ARMv6K CPUs.
>=20
In the patch that you applied:
8205/1 	add bitrev.h file to support rbit instruction

I have add :
+	select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6)

If you build kernel support ARMv6K, should CONFIG_CPU_V6=3Dy, isn't it ?
Then will not build hardware rbit instruction, isn't it ?

Thanks








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
