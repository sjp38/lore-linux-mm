Subject: Re: [PATCH 17/23] mm: count writeback pages per BDI
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708091225470.28074@schroedinger.engr.sgi.com>
References: <20070803123712.987126000@chello.nl>
	 <20070803125237.072937000@chello.nl>
	 <Pine.LNX.4.64.0708091214330.27092@schroedinger.engr.sgi.com>
	 <1186687416.11797.182.camel@lappy>
	 <Pine.LNX.4.64.0708091225470.28074@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fONaKnYZIJSZEqCzSeXq"
Date: Mon, 13 Aug 2007 10:36:39 +0200
Message-Id: <1186994199.20108.53.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

--=-fONaKnYZIJSZEqCzSeXq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-09 at 12:27 -0700, Christoph Lameter wrote:
> On Thu, 9 Aug 2007, Peter Zijlstra wrote:
>=20
> > Less conditionals. We already have a branch for mapping, why create
> > another?
>=20
> Ah. Okay. This also avoids an interrupt enable disable since you can use=20
> __ functions. Hmmm... Would be good if we could move the vmstat=20
> NR_WRITEBACK update there too. Can a page without a mapping be under=20
> writeback? (Direct I/O?)

DIO still uses the mapping afaik (it needs to invalidate the page before
and after the OP).

But you could put the increment in both paths, and use the irq disable
from the mapping branch - which should be the most frequent case anyway.

--=-fONaKnYZIJSZEqCzSeXq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGwBgXXA2jU0ANEf4RAsxcAJ9Kn809Vlp9vaVlD7HocGpCA2CA7gCfZmu+
GNyVHt1++OkEBR3zQPx/PNg=
=ejba
-----END PGP SIGNATURE-----

--=-fONaKnYZIJSZEqCzSeXq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
