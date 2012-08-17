Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DDF5B6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 03:49:22 -0400 (EDT)
Date: Fri, 17 Aug 2012 10:49:01 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, RFC 6/9] thp: add address parameter to
 split_huge_page_pmd()
Message-ID: <20120817074901.GA9833@otc-wbsnb-06>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1344503300-9507-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816194201.GQ11188@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline
In-Reply-To: <20120816194201.GQ11188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 16, 2012 at 09:42:01PM +0200, Andrea Arcangeli wrote:
> On Thu, Aug 09, 2012 at 12:08:17PM +0300, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >=20
> > It's required to implement huge zero pmd splitting.
> >=20
>=20
> This isn't bisectable with the next one, it'd fail on wfg 0-DAY kernel
> build testing backend, however this is clearly to separate this patch
> from the next, to keep the size small so I don't mind.

Hm. I don't see why it's not bisectable. It's only add a new parameter to
the function. The parameter is unused until next patch.

Actually, I've checked build bisectability with aiaiai[1].

[1] http://git.infradead.org/users/dedekind/aiaiai.git

--=20
 Kirill A. Shutemov

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQLfdtAAoJEAd+omnVudOM3rMQAIcawtMYkfooQfvwZvr6w3JW
oC0ege7lexwLyYvaEdPGMurV9cnUn8wsf66TlN8It43mdPGbCy3cQ0qMtFy2nBcn
BlD6vbDto7Gn6PUZmQhjQjHpYwiQhbFESeMJ23e9JlCy9M1i842VpePj4aXNpO3t
oF0basphC/R7+2dx3Ffi4JL3lP3B/cEapw+Mt3F1HJQc2aLN83AWnSiTvwMBkwzR
YWBDZzMrb5R0+fvdxgVH/B5gi97tWjT2mXTcmRKekKeP/lbrENYAo4ZXhSwIbQlc
FTil+YzgV3GG1lTb0wYbmTq4NYsJYt2DkSGWvDJVvRuZ6sEBwO3RC65IU+wmvTw9
L3PVxDNVEnGFrRRk2ePq8mlWEuxV1vvQFV8w1uOmWiZP5ef8eYSZXrXRNiRADbA9
+hk3IerQDdVG1Rk0gnjqlOLDVTxq4TYc3gfvKpYhrmoPd5qj/ELeE9fG/Vy/Lg3a
U1hCce8jK6hCFiTkEYsKvG3XRd6AvYYh1AtrOmOYgn6Wi9yE1TB8rTsDBClM/GEW
t0dsJPI8T4snylWGsWx+rMBZUYdHeyKyuNHHuVfMXRzg88UzkjCl/aeBFYeOiAtE
d88viONyShLty6X2Nlri0B6VQvQ3sb77o/UyPt279hGNTP102TNegF99OP+n6Unl
XLmVJXnf8pyqt2eGflzK
=HQXK
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
