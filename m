Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
From: Arjan van de Ven <arjanv@redhat.com>
In-Reply-To: <3DA4D3E4.6080401@us.ibm.com>
References: <3DA4D3E4.6080401@us.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-wDomlQKjTswTVu9O4R3M"
Date: 10 Oct 2002 11:00:00 +0200
Message-Id: <1034240403.1745.0.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-wDomlQKjTswTVu9O4R3M
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2002-10-10 at 03:12, Matthew Dobson wrote:
> Greetings & Salutations,
> 	Here's a wonderful patch that I know you're all dying for...  Memory=20
> Binding!  It works just like CPU Affinity (binding) except that it binds=20
> a processes memory allocations (just buddy allocator for now) to=20
> specific memory blocks.

If the VM works right just doing CPU binding ought to be enough, surely?


--=-wDomlQKjTswTVu9O4R3M
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9pUGQxULwo51rQBIRAmiBAJ9bH47Y0PghKaeOBa0ebkPHSLBq3wCfThkD
xrpn9kBrUdICX3nqcSLMM6Y=
=GiNr
-----END PGP SIGNATURE-----

--=-wDomlQKjTswTVu9O4R3M--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
