Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 41D4F6B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 06:24:59 -0400 (EDT)
Date: Sun, 31 May 2009 11:26:30 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
 sanitization
Message-ID: <20090531112630.2c7f4f1d@lxorguk.ukuu.org.uk>
In-Reply-To: <84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com>
References: <20090531015537.GA8941@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
	<84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-14
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > =A0 =A0 =A0 =A0memset(buf->data, 0, N_TTY_BUF_SIZE);
> > =A0 =A0 =A0 =A0if (PAGE_SIZE !=3D N_TTY_BUF_SIZE)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(...)
> > =A0 =A0 =A0 =A0else
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_page(...)
> >
> >
> > but quite frankly, I'm not convinced about these patches at all.
>=20
> I wonder why the tty code has that N_TTY_BUF_SIZE special casing in
> the first place? I think we can probably just get rid of it and thus
> we can use kzfree() here if we want to.

Some platforms with very large page sizes override the use of page based
allocators (eg older ARM would go around allocating 32K). The normal path
is 4K or 8K page sized buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
