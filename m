Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Michael Ellerman <michael@ellerman.id.au>
Reply-To: michael@ellerman.id.au
In-Reply-To: <20080731135016.GG1704@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	 <200807311626.15709.nickpiggin@yahoo.com.au>
	 <20080731112734.GE1704@csn.ul.ie>
	 <200807312151.56847.nickpiggin@yahoo.com.au>
	 <20080731135016.GG1704@csn.ul.ie>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZnN6y2vs7iwYgoQWASLw"
Date: Fri, 01 Aug 2008 00:32:55 +1000
Message-Id: <1217514775.19050.41.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Eric Munson <ebmunson@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--=-ZnN6y2vs7iwYgoQWASLw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-07-31 at 14:50 +0100, Mel Gorman wrote:
> On (31/07/08 21:51), Nick Piggin didst pronounce:
> > On Thursday 31 July 2008 21:27, Mel Gorman wrote:
> > > On (31/07/08 16:26), Nick Piggin didst pronounce:
> >=20
> > > > I imagine it should be, unless you're using a CPU with seperate TLB=
s for
> > > > small and huge pages, and your large data set is mapped with huge p=
ages,
> > > > in which case you might now introduce *new* TLB contention between =
the
> > > > stack and the dataset :)
> > >
> > > Yes, this can happen particularly on older CPUs. For example, on my
> > > crash-test laptop the Pentium III there reports
> > >
> > > TLB and cache info:
> > > 01: Instruction TLB: 4KB pages, 4-way set assoc, 32 entries
> > > 02: Instruction TLB: 4MB pages, 4-way set assoc, 2 entries
> >=20
> > Oh? Newer CPUs tend to have unified TLBs?
> >=20
>=20
> I've seen more unified DTLBs (ITLB tends to be split) than not but it cou=
ld
> just be where I'm looking. For example, on the machine I'm writing this
> (Core Duo), it's
>=20
> TLB and cache info:
> 51: Instruction TLB: 4KB and 2MB or 4MB pages, 128 entries
> 5b: Data TLB: 4KB and 4MB pages, 64 entries
>=20
> DTLB is unified there but on my T60p laptop where I guess they want the C=
PU
> to be using less power and be cheaper, it's
>=20
> TLB info
>  Instruction TLB: 4K pages, 4-way associative, 128 entries.
>  Instruction TLB: 4MB pages, fully associative, 2 entries
>  Data TLB: 4K pages, 4-way associative, 128 entries.
>  Data TLB: 4MB pages, 4-way associative, 8 entries

Clearly I've been living under a rock, but I didn't know one could get
such nicely formatted info.

In case I'm not the only one, a bit of googling turned up "x86info",
courtesy of davej - apt-get'able and presumably yum'able too.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-ZnN6y2vs7iwYgoQWASLw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIkc0XdSjSd0sB4dIRAjiFAKC/PVum23IXYylNmt+uZqHg6DDT4wCdGQqp
QYIRIcLptVPjBPD/Yma2Tqs=
=HNGl
-----END PGP SIGNATURE-----

--=-ZnN6y2vs7iwYgoQWASLw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
