Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB04900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:52:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so2144793pad.39
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 19:52:16 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id l3si2841288pdc.176.2014.10.28.19.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 19:52:15 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 10:52:08 +0800
Subject: RE: [RFC V3] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1825D@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18259@CNBJMBX05.corpusers.net>
 <20141027104848.GD8768@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825A@CNBJMBX05.corpusers.net>
 <20141028135944.GC29706@arm.com>
In-Reply-To: <20141028135944.GC29706@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>

> From: Will Deacon [mailto:will.deacon@arm.com]
> Yup, sorry, I didn't realise this patch covered both architectures. It
> would probably be a good idea to split it into 3 parts: a core part, then
> the two architectural bits.
>=20
> Will

Ok ,
I will split the patch into three parts,
And send again .

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
