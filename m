Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 88623900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 23:16:20 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so2198695pac.16
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 20:16:20 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id ab8si2989180pbd.32.2014.10.28.20.16.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 20:16:19 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 11:10:08 +0800
Subject: RE: [PATCH] 6fire: Convert byte_rev_table uses to bitrev8
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1825E@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
	 <1414531369.10912.14.camel@perches.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825C@CNBJMBX05.corpusers.net>
 <1414551974.10912.16.camel@perches.com>
In-Reply-To: <1414551974.10912.16.camel@perches.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joe Perches' <joe@perches.com>
Cc: Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, Russell King <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, alsa-devel <alsa-devel@alsa-project.org>, LKML <linux-kernel@vger.kernel.org>

> From: Joe Perches [mailto:joe@perches.com]
> > I think the most safe way is change byte_rev_table[] to be satic, So
> > that no driver can access it directly, The build error can remind the
> > developer if they use byte_rev_table[] Directly .
>=20
> You can do that with your later patch, but the existing uses _must_ be
> converted first so you don't break the build.
>=20
>=20
Yeah, I agree with you,
I will add this into my later patch.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
