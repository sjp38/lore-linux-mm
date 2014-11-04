Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 70D5E6B0099
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 20:45:50 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so13361657pad.11
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 17:45:50 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id gt8si16707025pbc.42.2014.11.03.17.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 17:45:48 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 4 Nov 2014 09:45:42 +0800
Subject: RE: [RFC V6 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18288@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18274@CNBJMBX05.corpusers.net>
 <20141031104305.GC6731@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18287@CNBJMBX05.corpusers.net>
 <CAKv+Gu-+fe9Hj-uGQHq8KR_6WjrQL-1q=xVBSXVXg2EJO=MW2w@mail.gmail.com>
 <20141103095051.GA23019@arm.com>
In-Reply-To: <20141103095051.GA23019@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joe Perches <joe@perches.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> From: Will Deacon [mailto:will.deacon@arm.com]
> >
> > If this is the case, I suggest you update patch 8187/1 to retain the
> > byte_rev_table symbol, even in the accelerated case, and remove it
> > with a followup patch once Joe's patches have landed upstream. Also, a
> > link to the patches would be nice, and perhaps a bit of explanation
> > how/when they are expected to be merged.
>=20
> Indeed, or instead put together a series with the appropriate acks so
> somebody can merge it all in one go. Merging this on a piecemeal basis is
> going to cause breakages (as you pointed out).
>=20
> Will

Hi  Will,
Could I add you as ack-by , and submit these 2 patches into the
Patch system ?
So you can merge them together .

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
