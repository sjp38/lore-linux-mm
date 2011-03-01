Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 901968D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 13:21:00 -0500 (EST)
Received: by vws13 with SMTP id 13so5992947vws.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 10:20:57 -0800 (PST)
Date: Tue, 1 Mar 2011 13:20:51 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/24] Refactor sys_swapon
Message-ID: <20110301182051.GB3664@mgebm.net>
References: <4D56D5F9.8000609@cesarb.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Content-Disposition: inline
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org


--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, 12 Feb 2011, Cesar Eduardo Barros wrote:

> This patch series refactors the sys_swapon function.
>=20
> sys_swapon is currently a very large function, with 313 lines (more
> than 12 25-line screens), which can make it a bit hard to read. This
> patch series reduces this size by half, by extracting large chunks
> of related code to new helper functions.
>=20
> One of these chunks of code was nearly identical to the part of
> sys_swapoff which is used in case of a failure return from
> try_to_unuse(), so this patch series also makes both share the same
> code.
>=20
> As a side effect of all this refactoring, the compiled code gets a
> bit smaller:
>=20
>    text	   data	    bss	    dec	    hex	filename
>   14012	    944	    276	  15232	   3b80	mm/swapfile.o.before
>   13941	    944	    276	  15161	   3b39	mm/swapfile.o.after
>=20
> Lightly tested on a x86_64 VM.

I have been working on reviewing/testing this set and I cannot get it
to apply to Linus' tree, what is this set based on?

Thanks,
Eric

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNbTkDAAoJEH65iIruGRnN6nQIAKuR1EfmOjtoYqJQNsfvDAKW
bg/59MtKx+qIWnwG5UIbTbsRmDYBajmlEc6PzhD3IjaL7ZmwHgfdB2c+RKJllQQR
PV7sVRFMG5c5UY7uBPc6smyUCUrUO4kfJIbJRMbh45aIvyMJMnsdJzHqL3d89zpn
cXf+QRot6vmQ791XfYmMeWn7w8TBa5rjchjQ+qutvSiUKpRJ1hajvacSPSlVcC97
rSgTBqZCVnssIKozMrryzsIwozr9VMtwly4aYC97FRnGOkdxL/JQif6iey0CLI82
Jh9EAOyNLNO2cOO/fcQiqQY4xGBD3YsXJS6AhMpCjh9so1USt66HpimjN14CxqM=
=49ML
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
