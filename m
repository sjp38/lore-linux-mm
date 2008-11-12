Date: Wed, 12 Nov 2008 17:57:17 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [patch 0/7] cpu alloc stage 2
Message-Id: <20081112175717.4a1fd679.sfr@canb.auug.org.au>
In-Reply-To: <20081105231634.133252042@quilx.com>
References: <20081105231634.133252042@quilx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__12_Nov_2008_17_57_17_+1100_5RjKAKZ.3LbmM6=8"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__12_Nov_2008_17_57_17_+1100_5RjKAKZ.3LbmM6=8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Christoph,

On Wed, 05 Nov 2008 17:16:34 -0600 Christoph Lameter <cl@linux-foundation.o=
rg> wrote:
>
> The second stage of the cpu_alloc patchset can be pulled from
>=20
> git.kernel.org/pub/scm/linux/kernel/git/christoph/work.git cpu_alloc_stag=
e2
>=20
> Stage 2 includes the conversion of the page allocator
> and slub allocator to the use of the cpu allocator.
>=20
> It also includes the core of the atomic vs. interrupt cpu ops and uses th=
ose
> for the vm statistics.

I have seen some discussion of these patches (and some fixes for the
previous set).  Are they in a state that they should be in linux-next yet?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__12_Nov_2008_17_57_17_+1100_5RjKAKZ.3LbmM6=8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkkafk0ACgkQjjKRsyhoI8x0LQCgndfW9F523hxXsVIO3QXMRIBM
DkYAnjtoJJ/37qfEPc963t/g/B8qFh/G
=rT4/
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Nov_2008_17_57_17_+1100_5RjKAKZ.3LbmM6=8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
