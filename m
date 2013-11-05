Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB4A6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 21:08:36 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7768011pab.14
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 18:08:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id ei3si12001922pbc.20.2013.11.04.18.08.33
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 18:08:34 -0800 (PST)
Date: Tue, 5 Nov 2013 13:08:14 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131105130814.7127298d@notabene.brown>
In-Reply-To: <CAF7GXvpJVLYDS5NfH-NVuN9bOJjAS5c1MQqSTjoiVBHJt6bWcw@mail.gmail.com>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
	<20131025214952.3eb41201@notabene.brown>
	<alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
	<154617470.12445.1382725583671.JavaMail.mail@webmail11>
	<20131026074349.0adc9646@notabene.brown>
	<476525596.14731.1382735024280.JavaMail.mail@webmail11>
	<20131026091112.241da260@notabene.brown>
	<CAF7GXvpJVLYDS5NfH-NVuN9bOJjAS5c1MQqSTjoiVBHJt6bWcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/gVWr30a.5_RNZoFmDoCa/kl"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, david@lang.hm, lkml <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, Linux-MM <linux-mm@kvack.org>

--Sig_/gVWr30a.5_RNZoFmDoCa/kl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 5 Nov 2013 09:40:55 +0800 "Figo.zhang" <figo1802@gmail.com> wrote:

> > >
> > > Of course, if you don't use Linux on the desktop you don't really car=
e -
> > well, I do. Also
> > > not everyone in this world has an UPS - which means such a huge buffer
> > can lead to a
> > > serious data loss in case of a power blackout.
> >
> > I don't have a desk (just a lap), but I use Linux on all my computers a=
nd
> > I've never really noticed the problem.  Maybe I'm just very patient, or
> > maybe
> > I don't work with large data sets and slow devices.
> >
> > However I don't think data-loss is really a related issue.  Any process
> > that
> > cares about data safety *must* use fsync at appropriate places.  This h=
as
> > always been true.
> >
> > =3D>May i ask question that, some like ext4 filesystem, if some app mot=
ify
> the files, it create some dirty data. if some meta-data writing to the
> journal disk when a power backout,
> it will be lose some serious data and the the file will damage?

If you modify a file, then you must take care that you can recover from a
crash at any point in the process.

If the file is small, the usual approach is to create a copy of the file wi=
th
the appropriate changes made, then 'fsync' the file and rename the new file
over the old file.

If the file is large you might need some sort of update log (in a small fil=
e)
so you can replay recent updates after a crash.

The  journalling that the filesystem provides only protects the filesystem
metadata.  It does not protect the consistency of the data in your file.

I hope  that helps.

NeilBrown

--Sig_/gVWr30a.5_RNZoFmDoCa/kl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUnhTDjnsnt1WYoG5AQL8UhAAsymCSPXOccBun3EqBLddwOqwUyyiZq2l
WxRF5e8qbj1r48FPPDVzVPxDwu91n0Er+QC1D/tC2NUxwC4rx0LNqigGAcI2l3Ic
JUeNfZfaO3Gm1KcNqqdk25qOa+7mJoMakkIuQ6GQX5DtefeMiUEW6svTXsKt0nGW
3qOudkFCf3hyux/NQBNKvlsk4ljbfKyaVrOCIoxmT4js/BzxHOlkB7Vj7cnRM/Q0
DasihAIzIWKFTCqQCKhB0xMwD53XjurYGKIdMfPhmjUYOh4c42wF/Hy2h9vFm9Px
6jK+LS/XCxHt/+EiAj4LEBEeyCbfKCgOabV+qsgH+qP8yR89I/k5iGTaq4+I2rib
lko5VSqUdnGvUt/GbubbCAf5DvH/dcZM1sddT+/iqI9XyA9+vvVTFOHJUW1E2ZSX
jYpuZiTabCcSNZQeBFrwMzxtjj0m102mLW1jbyesIGtBbR8ozDqxplZqeyMKblMH
2yLTkv7hjANpayAiBHWB1bHHrH2GjxAf/iYToeBqB4gt45+FQIjwkcUzdUFMU/bP
iPnvtflafvHGaQWI99rkrN5Kaoi9UcPlKxUd+xA9EJOpFgyZGAwFvge8QzlxH5up
Pxtk2RCYVWaTznzRT40qVe/2CBzwPbH2XyAWcTdQBGLFj7TzqKEp38bnakG3mB9e
nq8sQ97WdMs=
=PdUs
-----END PGP SIGNATURE-----

--Sig_/gVWr30a.5_RNZoFmDoCa/kl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
