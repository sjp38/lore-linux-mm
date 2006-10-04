Date: Wed, 4 Oct 2006 18:12:54 +0200
From: Andre Noll <maan@systemlinux.org>
Subject: Re: 2.6.18: Kernel BUG at mm/rmap.c:522
Message-ID: <20061004161254.GE22487@skl-net.de>
References: <20061004104018.GB22487@skl-net.de> <4523BE45.5050205@yahoo.com.au> <20061004154227.GD22487@skl-net.de> <1159976940.27331.0.camel@twins>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zaRBsRFn0XYhEU69"
Content-Disposition: inline
In-Reply-To: <1159976940.27331.0.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andrea@suse.de, riel@redhat.com
List-ID: <linux-mm.kvack.org>

--zaRBsRFn0XYhEU69
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 17:49, Peter Zijlstra wrote:

> enable CONFIG_DEBUG_VM to get that.

Yup, that was disabled. It's enabled now.

Thanks
Andre

--=20
The only person who always got his work done by Friday was Robinson Crusoe

--zaRBsRFn0XYhEU69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFFI92GWto1QDEAkw8RAmUHAJ9BxUxT/eVyHfx2hT5ZDEyMirnhTQCfU0HR
JOOgzODwzqTNhlOoKLLmOYM=
=BXVh
-----END PGP SIGNATURE-----

--zaRBsRFn0XYhEU69--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
