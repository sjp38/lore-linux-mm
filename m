Subject: Re: [PATCH] shrink per_cpu_pages to fit 32byte cacheline
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20040913233835.GA23894@logos.cnet>
References: <20040913233835.GA23894@logos.cnet>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pezfflIUTYShj6qFhiWu"
Message-Id: <1095142204.2698.12.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Tue, 14 Sep 2004 08:10:04 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-pezfflIUTYShj6qFhiWu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-09-14 at 01:38, Marcelo Tosatti wrote:
> Subject says it all, the following patch shrinks per_cpu_pages
> struct from 24 to 16bytes, that makes the per CPU array containing
> hot and cold "per_cpu_pages[2]" fit on 32byte cacheline. This structure
> is often used so I bet this is a useful optimization.

I'm not sure it's worth it. cachelines are 64 or 128 bytes nowadays and
a short access costs you at least 1 extra cycle per access on several
x86 cpus (byte and dword are cheap, short is not)


--=-pezfflIUTYShj6qFhiWu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBRos8xULwo51rQBIRApRBAKCEQI6ROdhtuEwET+va5dyPCnG33gCgjniy
Bzn+uGxkiCB00vvDIo+/0Ag=
=v/O0
-----END PGP SIGNATURE-----

--=-pezfflIUTYShj6qFhiWu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
