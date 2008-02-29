From: "=?utf-8?q?S=2E=C3=87a=C4=9Flar?= Onur" <caglar@pardus.org.tr>
Reply-To: caglar@pardus.org.tr
Subject: Re: trivial clean up to zlc_setup
Date: Fri, 29 Feb 2008 15:31:34 +0200
References: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080229000544.5cf2667e.akpm@linux-foundation.org> <20080229171136.66F6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080229171136.66F6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7846280.53EjfgUmJ3";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200802291531.36498.caglar@pardus.org.tr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--nextPart7846280.53EjfgUmJ3
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi;

29 =C5=9Eub 2008 Cum tarihinde, KOSAKI Motohiro =C5=9Funlar=C4=B1 yazm=C4=
=B1=C5=9Ft=C4=B1:=20
> > > -       if (jiffies - zlc->last_full_zap > 1 * HZ) {
> > > +       if (time_after(jiffies, zlc->last_full_zap + HZ)) {
> > >                 bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
> > >                 zlc->last_full_zap =3D jiffies;
> > >         }
> >=20
> > That's a mainline bug.  Also present in 2.6.24, maybe earlier.
> > But it's a minor one - we'll fix it up one second later (yes?)
>=20
> I think so, may be.

Andrew "Use time_* macros" series i sent to LKML on 14 Feb [1] has this chu=
nk also (and by the way this version not includes linux/jiffies.h for time_=
after macro). Some part of this series already gone into Linus's tree with =
different subsystems but others not received any review/ack or nack. Will y=
ou grab others for -mm or will i resend them?

[1] http://lkml.org/lkml/2008/2/14/195

Cheers
=2D-=20
S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
http://cekirdek.pardus.org.tr/~caglar/

Linux is like living in a teepee. No Windows, no Gates and an Apache in hou=
se!

--nextPart7846280.53EjfgUmJ3
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4 (GNU/Linux)

iD8DBQBHyAk4y7E6i0LKo6YRAkedAJ0bV2dspLjQsgMFMaaRDnirS3SotACfTWRO
nOAUG5qHfNizTv8y5xyYW2M=
=D4sN
-----END PGP SIGNATURE-----

--nextPart7846280.53EjfgUmJ3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
