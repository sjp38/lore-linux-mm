Date: Tue, 15 Nov 2005 09:27:02 -0500
From: "Scott F. H. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: why its dead now?
Message-ID: <20051115142702.GC31096@sirius.cs.amherst.edu>
References: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wxDdMuZNg1r63Hyj"
Content-Disposition: inline
In-Reply-To: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta.mail@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--wxDdMuZNg1r63Hyj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 14, 2005 at 12:05:58AM +0530, Nitin Gupta wrote:

> I'm wondering why this project is dead even when it showed great
> performance improvement when system is under memory pressure.

As he stated himself, the primary reason is that its primary
maintainer (Rodrigo) can no longer dedicate time to it.

> Are there any serious drawbacks to this?

As Rik pointed out, the main complication is adapting the compressed
cache size which can be trickier for some workloads than others.  The
original, 2.4.x-line of linuxcompressed used a method of adaptivity
developed by those working on that project.  It seemed to work for
many cases, but also could suffer performance degredation for some
workloads.

There is also the possibility of the adaptive method about which I
wrote in my dissertation and in a USENIX 1999 paper (see the
linuxcompressed page -- I believe it has links for these).  This
adaptive method is much less likely to adapt badly for some workloads,
but it also requires more extensive changes to the way in which the
kernel stores referencing history.

For completely different purposes, we have a 2.4.x kernel that
maintains this history efficiently.  If you (or anyone else) are
interested at some point in porting this reference-pattern-gathering
code forward to the 2.6.x line, then you could easily apply this other
adaptive mechanism to compressed caching.

> Do you think it will be of any use if ported to 2.6 kernel?

Sure.  I think that the potential for compressed caching to ease the
performance degredation under memory pressure is only getting better
as hardware continues to evolve.

Scott

--wxDdMuZNg1r63Hyj
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFDefA28eFdWQtoOmgRAhHQAJ4oMEgHnvu/q0If854DMvrGXKrbZgCgn8M5
0/VLRcbq72tIc/7E5HRpDps=
=zTMe
-----END PGP SIGNATURE-----

--wxDdMuZNg1r63Hyj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
