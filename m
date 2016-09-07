Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF546B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 20:45:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 44so736455qtf.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 17:45:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j197si3679962ybj.315.2016.09.06.17.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 17:45:22 -0700 (PDT)
Message-ID: <1473209119.32433.174.camel@redhat.com>
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Sep 2016 20:45:19 -0400
In-Reply-To: <e2e8b8fc-3deb-aa23-c54e-43f12dd0a941@gmail.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
	 <e2e8b8fc-3deb-aa23-c54e-43f12dd0a941@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-eCegwyLach2nn8zbkR2h"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-eCegwyLach2nn8zbkR2h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-08-31 at 09:24 -0400, nick wrote:
>=20
> On 2016-08-31 03:54 AM, Catalin Marinas wrote:
> > On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
> > > This fixes a issue in the current locking logic of the function,
> > > __delete_object where we are trying to attempt to lock the passed
> > > object structure's spinlock again after being previously held
> > > elsewhere by the kmemleak code. Fix this by instead of assuming
> > > we are the only one contending for the object's lock their are
> > > possible other users and create two branches, one where we get
> > > the lock when calling spin_trylock_irqsave on the object's lock
> > > and the other when the lock is held else where by kmemleak.
> >=20
> > Have you actually got a deadlock that requires this fix?
> >=20
> Yes I have got a deadlock that this does fix.

Why don't you share the backtrace with us?

Claiming you have a deadlock, but not sharing
it on the list means nobody can see what the
problem is you are trying to address.

It would be good if every email with a patch
that you post starts with an actual detailed
problem description.

Can you do that?

--=20

All Rights Reversed.
--=-eCegwyLach2nn8zbkR2h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXz2MfAAoJEM553pKExN6DxSEH/iEY6vsZa6T3kRb3T9yCDzG0
Vc+5o/9OkAKca4y+dfRfK17rYpRIwfAhhzAgFqxKXO68Hbg+MRIR7nvLbyou7HN9
lCFzsjROgIIBsjA7qp6K6qAD7vUheVxkEw67DJ/gdiZZMd+ZEjwJMAMtXI9T0lPD
RsofczPuR933m3i8NaLucvK+W6AqDUgeJ0mLKiL4TBMoWPFQ72rqk06GmIr87T4u
7hNz4EaFFGj5C8f54/r44ZqTZt7o+h2A4KUrMs+4DbIAyYk7P31lk0S425wVXuBt
NRCreghupr+lV7xtOwb2xSEGGXbgTJX0HbTfg96+UEycCAyyeHCpBpgiuaP7ARs=
=eNlz
-----END PGP SIGNATURE-----

--=-eCegwyLach2nn8zbkR2h--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
