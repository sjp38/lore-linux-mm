Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C13376B0003
	for <int-list-linux-mm@kvack.org>; Fri, 16 Feb 2018 09:34:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v2so941209wmf.7
        for <int-list-linux-mm@kvack.org>; Fri, 16 Feb 2018 06:34:02 -0800 (PST)
Date: Fri, 16 Feb 2018 15:34:01 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180216143401.GA3439@amd>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
 <20180214104342.GA12209@amd>
 <20180215034444.GA18849@zipoli.concurrent-rt.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Content-Disposition: inline
In-Reply-To: <20180215034444.GA18849@zipoli.concurrent-rt.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joe.korty@concurrent-rt.com
Cc: Andy Lutomirski <luto@amacapital.net>, int-list-linux-mm@kvack.orglinux-mm@kvack.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2018-02-14 22:44:44, joe.korty@concurrent-rt.com wrote:
> On Wed, Feb 14, 2018 at 11:43:42AM +0100, Pavel Machek wrote:
> > We have just found out that majority of 64-bit machines are broken in
> > rather fundamental ways (Spectre) and Intel does not even look
> > interested in fixing that (because it would make them look bad on
> > benchmarks).
> >=20
> > Even when the Spectre bug is mitigated... this looks like can of worms
> > that can not be closed.
> >=20
> > OTOH -- we do know that there are non-broken machines out there,
> > unfortunately they are mostly 32-bit :-). Removing support for
> > majority of working machines may not be good idea...
> >=20
> > [And I really hope future CPUs get at least option to treat cache miss
> > as a side-effect -- thus disalowed during speculation -- and probably
> > option to turn off speculation altogether. AFAICT, it should "only"
> > result in 50% slowdown -- or that was result in some riscv
> > presentation.]
>=20
> Or, future CPU designs introduce shadow caches and shadow
> TLBs which only speculation loads and sees and which
> become real only if and whend the resultant speculative
> calculations become real.

Yes, that could help.

But there's still sidechannel in the RAM: it has row buffer
or something like that.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlqG69kACgkQMOfwapXb+vLGTACghGGkiTTeLlDWnrbdCN8J59b2
qMAAoLcbHU825oLyqqm8NqO3a+NRUySM
=oZYw
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
