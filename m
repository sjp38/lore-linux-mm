Subject: Re: 2.5.59-mm2
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20030118002027.2be733c7.akpm@digeo.com>
References: <20030118002027.2be733c7.akpm@digeo.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WHsfDqNlNROI9SmuFvTv"
Message-Id: <1042920761.15782.5.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: 18 Jan 2003 21:12:41 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, nitin.a.kamble@intel.com, jun.nakajima@intel.com, asit.k.mallick@intel.com, sunil.saxena@intel.com
List-ID: <linux-mm.kvack.org>

--=-WHsfDqNlNROI9SmuFvTv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> +kirq-up-fix.patch
>=20
>  Fix the kirq build for non-SMP

Hi,

Is there any reason to put this complexity in the kernel instead of
doing it from a userspace daemon?

A userspace daemon can do higher level evaluations, read config files
about the system (like numa configuration etc etc) and all 2.4/2.5
kernels already have a userspace api for setting irq affinity..

an example of a simple version of such daemon is:
http://people.redhat.com/arjanv/irqbalance/irqbalance-0.03.tar.gz

any chance of testing this in an intel lab?

Greetings,
     Arjan van de Ven

--=-WHsfDqNlNROI9SmuFvTv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA+KbU5xULwo51rQBIRAs3yAJsEcLzbrvTdU6NbEd4c8NHjdiDKZQCfQ3QE
smDeLZLj8ZsZi7H6b6y1cFU=
=l28J
-----END PGP SIGNATURE-----

--=-WHsfDqNlNROI9SmuFvTv--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
