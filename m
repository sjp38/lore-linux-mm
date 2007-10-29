Date: Mon, 29 Oct 2007 14:24:30 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] slub: nr_slabs is an atomic_long_t
Message-Id: <20071029142430.fd711666.sfr@canb.auug.org.au>
In-Reply-To: <Pine.LNX.4.64.0710281953460.28636@schroedinger.engr.sgi.com>
References: <20071029131540.13932677.sfr@canb.auug.org.au>
	<Pine.LNX.4.64.0710281953460.28636@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__29_Oct_2007_14_24_30_+1100_ZcV1Ey37w+5FIBwc"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--Signature=_Mon__29_Oct_2007_14_24_30_+1100_ZcV1Ey37w+5FIBwc
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 28 Oct 2007 19:53:55 -0700 (PDT) Christoph Lameter <clameter@sgi.co=
m> wrote:
>
> That was already fixed AFAICT.

Not in Linus' tree, yet.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__29_Oct_2007_14_24_30_+1100_ZcV1Ey37w+5FIBwc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHJVJzTgG2atn1QN8RAgG1AKCLcBxSZe+qtqIi1e996D1d8HZpWgCcC4Ys
zzrzCsI0HPAr8SGccsn/yic=
=axac
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Oct_2007_14_24_30_+1100_ZcV1Ey37w+5FIBwc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
