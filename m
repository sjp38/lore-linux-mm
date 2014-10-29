Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 860006B00BC
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:36:37 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so2452018pad.3
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:36:37 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id ml2si3137277pab.144.2014.10.28.22.36.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 22:36:36 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 13:36:30 +0800
Subject: RE: [RFC V4 1/3] add CONFIG_HAVE_ARCH_BITREVERSE to support rbit
 instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18263@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
	 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <1414560096.10912.18.camel@perches.com>
In-Reply-To: <1414560096.10912.18.camel@perches.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joe Perches' <joe@perches.com>
Cc: 'Rob Herring' <robherring2@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> From: Joe Perches [mailto:joe@perches.com]
> > We also change byte_rev_table[] to be static, to make sure no drivers
> > can access it directly.
>=20
> You break the build with this patch.
>=20
> You can't do this until the users of the table are converted.
>=20
> So far, they are not.
>=20
> I submitted patches for these uses, but those patches are not yet applied=
.
>=20
> Please make sure the dependencies for your patches are explicitly stated.
>=20
Oh,  byte_rev_table[] must be extern,
Otherwise, bitrev8() can't access it ,
I will change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
