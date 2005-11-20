Date: Sat, 19 Nov 2005 21:24:10 -0500
From: "Scott F. H. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: why its dead now?
Message-ID: <20051120022410.GA5999@sirius.cs.amherst.edu>
References: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com> <20051115142702.GC31096@sirius.cs.amherst.edu> <Pine.LNX.4.63.0511191829100.13937@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0511191829100.13937@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nitin Gupta <nitingupta.mail@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Rik,

On Sat, Nov 19, 2005 at 06:30:01PM -0500, Rik van Riel wrote:
> On Tue, 15 Nov 2005, Scott F. H. Kaplan wrote:
>=20
> > For completely different purposes, we have a 2.4.x kernel that
> > maintains this history efficiently.  If you (or anyone else) are
> > interested at some point in porting this reference-pattern-gathering
> > code forward to the 2.6.x line,
>=20
> Marcelo already did some work on that:
>=20
> 	http://linux-mm.org/PageTrace

Nope.  Marcelo's work on reference trace collection overlaps with
other work I've done (kVMTrace), but I'm referring to something
completely different.

Specifically, I'm talking about gathering LRU miss histograms
(A.K.A. ``miss rate curves'') online in the kernel.  A paper in ASPLOS
2004 presented this idea, as did we in an ISMM 2004 paper on
automatically resizing garbage collectors.  We have a kernel with much
lower overhead than the ASPLOS paper presents.

These histograms can be used to perform various kinds of cost/benefit
calculations for current reference patterns.  In this case, it could
be used to implement the method I presented in a USENIX 1999 paper for
dynamically adaptic compressed cache sizes.  It's a mechanism that
would be difficult to trick into maladaptivity.

Scott

--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFDf95K8eFdWQtoOmgRAhorAKCoHtnNgCiQ6RqPcBSFD1zWLz6lpwCeIMjq
PISTxGWfsXu4fVK6wzS9SAI=
=0ieF
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
