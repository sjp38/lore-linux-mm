Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A52D26B006E
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:13:59 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1841541pdb.13
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:13:59 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id nr9si9785010pbc.113.2014.10.27.00.13.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 00:13:58 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 27 Oct 2014 15:13:50 +0800
Subject: RE: [RFC V2] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18258@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
In-Reply-To: <1414392371.8884.2.camel@perches.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joe Perches' <joe@perches.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>



>=20
> If this is done, the direct uses of byte_rev_table in
> drivers/net/wireless/ath/carl9170/phy.c and sound/usb/6fire/firmware.c
> should be converted too?
>=20

I think use bitrev8()  is safer than to use byte_rev_table[]  directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
