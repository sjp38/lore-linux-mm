Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 739576B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:19:38 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g9-v6so11249761wrq.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:19:38 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id g14-v6si13752286wrg.131.2018.07.31.02.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 02:19:37 -0700 (PDT)
Date: Tue, 31 Jul 2018 11:19:35 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv2] pm/reboot: eliminate race between reboot and suspend
Message-ID: <20180731091935.GB9836@amd>
References: <1533027092-15085-1-git-send-email-kernelfans@gmail.com>
 <CAJZ5v0gLz4vLiiyfEsMc8FHhm3s0zGNaYRiye-1Tj85BZkv+ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Content-Disposition: inline
In-Reply-To: <CAJZ5v0gLz4vLiiyfEsMc8FHhm3s0zGNaYRiye-1Tj85BZkv+ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Pingfan Liu <kernelfans@gmail.com>, Linux PM <linux-pm@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2018-07-31 11:07:01, Rafael J. Wysocki wrote:
> On Tue, Jul 31, 2018 at 10:51 AM, Pingfan Liu <kernelfans@gmail.com> wrot=
e:
> > At present, "systemctl suspend" and "shutdown" can run in parrallel. A
> > system can suspend after devices_shutdown(), and resume. Then the shutd=
own
> > task goes on to power off. This causes many devices are not really shut
> > off. Hence replacing reboot_mutex with system_transition_mutex (renamed
> > from pm_mutex) to achieve the exclusion. The renaming of pm_mutex as
> > system_transition_mutex can be better to reflect the purpose of the mut=
ex.
> >
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <len.brown@intel.com>
> > Cc: Pavel Machek <pavel@ucw.cz>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > ---
> > v1 -> v2:
> >  rename pm_mutex as system_transition_mutex
>=20
> LGTM
>=20
> I can queue this up for 4.19 unless there are objections.

Acked-by: Pavel Machek <pavel@ucw.cz>

[Documentation lines are now too long and multi-line comment coding
style is nonstandard AFAICT, but... lets apply this.]

> > -/* indicate whether PM freezing is in effect, protected by pm_mutex */
> > +/* indicate whether PM freezing is in effect, protected by
> > + * system_transition_mutex
> > + */

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltgKacACgkQMOfwapXb+vLMAgCgm5JCJXv2lzB886Koddr6e2Ei
GIEAoJPD011fTFtnwyZxI09q91us7Rwn
=Rgr3
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--
