Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B05C56B011A
	for <linux-mm@kvack.org>; Sun,  2 Nov 2014 21:17:23 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so10721525pdj.0
        for <linux-mm@kvack.org>; Sun, 02 Nov 2014 18:17:23 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id rb7si14243077pab.142.2014.11.02.18.17.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 02 Nov 2014 18:17:22 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 3 Nov 2014 10:17:15 +0800
Subject: RE: [RFC V6 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18287@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18274@CNBJMBX05.corpusers.net>
 <20141031104305.GC6731@arm.com>
In-Reply-To: <20141031104305.GC6731@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> From: Will Deacon [mailto:will.deacon@arm.com]
> > +#ifndef __ASM_ARM64_BITREV_H
> > +#define __ASM_ARM64_BITREV_H
>=20
> Really minor nit, but we don't tend to include 'ARM64' in our header guar=
ds,
> so this should just be __ASM_BITREV_H.
>=20
> With that change,
>=20
>   Acked-by: Will Deacon <will.deacon@arm.com>
>=20
I have send the patch to the patch system:
http://www.arm.linux.org.uk/developer/patches/search.php?uid=3D4025

8187/1 8188/1 8189/1

Just remind you that , should also cherry-pick Joe Perches's=20
2 patches:
[PATCH] 6fire: Convert byte_rev_table uses to bitrev8
[PATCH] carl9170: Convert byte_rev_table uses to bitrev8

To make sure there is no build error when build these 2 drivers.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
