Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C3AC6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 02:03:20 -0400 (EDT)
Date: Wed, 16 Sep 2009 16:03:13 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: 2.6.32 -mm Blackfin patches
Message-Id: <20090916160313.aeb61ef7.sfr@canb.auug.org.au>
In-Reply-To: <20090915211810.d1b83015.akpm@linux-foundation.org>
References: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
	<20090915211810.d1b83015.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Sep_2009_16_03_13_+1000_pJOTdue2ivI16kT."
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bryan Wu <cooloney.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__16_Sep_2009_16_03_13_+1000_pJOTdue2ivI16kT.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew, Mike,

On Tue, 15 Sep 2009 21:18:10 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Tue, 15 Sep 2009 23:56:21 -0400 Mike Frysinger <vapier.adi@gmail.com> =
wrote:
>=20
> > On Tue, Sep 15, 2009 at 19:15, Andrew Morton wrote:
> > > blackfin-convert-to-use-arch_gettimeoffset.patch
> >=20
> > i thought John was merging this via some sort of patch series, but i
> > can pick it up in the Blackfin tree to make sure things are really
> > sane
>=20
> Sent.
>=20
> > > blackfin-fix-read-buffer-overflow.patch
> >=20
> > the latter patch i merged into my tree (and i thought that i followed
> > up in the original posting about this)
>=20
> Well, it isn't in linux-next so as far as I'm concerned I have the
> only copy.  Should you be getting your tree into linux-next?

There is a blackfin tree in linux-next managed by Bryan Wu:

git://git.kernel.org/pub/scm/linux/kernel/git/cooloney/blackfin-2.6.git#for=
-linus

As far as I can tell, it hasn't bee updated since March 30.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__16_Sep_2009_16_03_13_+1000_pJOTdue2ivI16kT.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkqwf6EACgkQjjKRsyhoI8xV9wCeME8MJjeIf9UJeTaoGCC77VRR
4/IAn3sWPvY6DBs4xhIEMThx3dIQRRFy
=I6GP
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Sep_2009_16_03_13_+1000_pJOTdue2ivI16kT.--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
