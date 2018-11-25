Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 25 Nov 2018 23:04:44 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v8 0/7] mm: Merge hmm into devm_memremap_pages, mark
 GPL-only
Message-ID: <20181125220444.GA30242@amd>
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181121172055.91dc52fc0b985be85e640328@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Content-Disposition: inline
In-Reply-To: <20181121172055.91dc52fc0b985be85e640328@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org
List-ID: <linux-mm.kvack.org>


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Changes since v7 [1]:
> > At Maintainer Summit, Greg brought up a topic I proposed around
> > EXPORT_SYMBOL_GPL usage. The motivation was considerations for when
> > EXPORT_SYMBOL_GPL is warranted and the criteria for taking the
> > exceptional step of reclassifying an existing export. Specifically, I
> > wanted to make the case that although the line is fuzzy and hard to
> > specify in abstract terms, it is nonetheless clear that
> > devm_memremap_pages() and HMM (Heterogeneous Memory Management) have
> > crossed it. The devm_memremap_pages() facility should have been
> > EXPORT_SYMBOL_GPL from the beginning, and HMM as a derivative of that
> > functionality should have naturally picked up that designation as well.
> >=20
> > Contrary to typical rules, the HMM infrastructure was merged upstream
> > with zero in-tree consumers. There was a promise at the time that those
> > users would be merged "soon", but it has been over a year with no drive=
rs
> > arriving. While the Nouveau driver is about to belatedly make good on
> > that promise it is clear that HMM was targeted first and foremost at an
> > out-of-tree consumer.

Ok, so who is this consumer and is he GPLed?

> It should be noted that [7/7] has a cc:stable.

That is pretty evil thing to do, right?

The aim here is not to fix "a real bug that hits people", AFAICT. The
aim is to break existing configurations for users.

Political games are sometimes neccessary, but should not really be
played with stable.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlv7HHwACgkQMOfwapXb+vLS2QCdGLrC5x+ES/mY7gi/L7zIzTjd
BYsAn2//n2PuJ6KNErZ6Uy4a0fSjEiOE
=i+UE
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
