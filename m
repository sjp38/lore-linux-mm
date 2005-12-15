Date: Thu, 15 Dec 2005 02:01:38 +0100
From: "J.A. Magallon" <jamagallon@able.es>
Subject: Re: [RFC3 01/14] Add some consts for inlines in mm.h
Message-ID: <20051215020138.171e1cdd@werewolf.auna.net>
In-Reply-To: <20051215001420.31405.76332.sendpatchset@schroedinger.engr.sgi.com>
References: <20051215001415.31405.24898.sendpatchset@schroedinger.engr.sgi.com>
	<20051215001420.31405.76332.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary=Sig_yWhYnNVu.C8+2nxP2ljNeGa;
 protocol="application/pgp-signature"; micalg=PGP-SHA1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

--Sig_yWhYnNVu.C8+2nxP2ljNeGa
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 14 Dec 2005 16:14:20 -0800 (PST), Christoph Lameter <clameter@sgi.c=
om> wrote:

> [PATCH] const attributes for some inlines in mm.h
>=20
> Const attributes allow the compiler to generate more efficient code by
> allowing callers to keep arguments of struct page in registers.
>=20

Even if it does not keep them in registers, at least it doesn't duplicate
them...

--
J.A. Magallon <jamagallon()able!es>     \               Software is like se=
x:
werewolf!able!es                         \         It's better when it's fr=
ee
Mandriva Linux release 2006.1 (Cooker) for i586
Linux 2.6.14-jam4 (gcc 4.0.2 (4.0.2-1mdk for Mandriva Linux release 2006.1))

--Sig_yWhYnNVu.C8+2nxP2ljNeGa
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDoMByRlIHNEGnKMMRAlY2AJ9BOfl8TiS1LFwZCEm7doFWDCl1aQCeJVNF
53yql0dHIeSTroVD3xCRU0E=
=re74
-----END PGP SIGNATURE-----

--Sig_yWhYnNVu.C8+2nxP2ljNeGa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
