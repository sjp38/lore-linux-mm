From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [RFC] sys_punchhole()
Date: Fri, 11 Nov 2005 09:25:41 +0100
References: <1131664994.25354.36.camel@localhost.localdomain> <20051110153254.5dde61c5.akpm@osdl.org>
In-Reply-To: <20051110153254.5dde61c5.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2834990.SANAYd45pA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200511110925.48259.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart2834990.SANAYd45pA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

On Friday 11 November 2005 00:32, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > We discussed this in madvise(REMOVE) thread - to add support=20
> > for sys_punchhole(fd, offset, len) to complete the functionality
> > (in the future).
> >=20
> > http://marc.theaimsgroup.com/?l=3Dlinux-mm&m=3D113036713810002&w=3D2
> >=20
> > What I am wondering is, should I invest time now to do it ?
>=20
> I haven't even heard anyone mention a need for this in the past 1-2 years.

Because the people need it are usally at the application level.
It would be useful with hard disk editing.

But this would need a move_blocks within the filesystem, which
could attach a given list of blocks to another file.

E.g. mremap() for files :-)

Both together would make harddisk video editing with linux quite
performant and less error prone.


Regards

Ingo Oeser


--nextPart2834990.SANAYd45pA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDdFWMU56oYWuOrkARAs5bAKCUWeuUxd7AWdVsC4jDANe0KvlQRwCdHnBz
shv9TBiCqFQ2+WQTas5FK6w=
=2JyA
-----END PGP SIGNATURE-----

--nextPart2834990.SANAYd45pA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
