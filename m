Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
From: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <E17n25p-0006AQ-00@starship>
References: <1031246639.2799.68.camel@spc9.esa.lanl.gov>
	<E17n25p-0006AQ-00@starship>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-6RKGPRFyXIUe5eDEPWV7"
Date: 06 Sep 2002 01:38:50 +0200
Message-Id: <1031269130.5760.318.camel@tux>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-6RKGPRFyXIUe5eDEPWV7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2002-09-05 at 21:15, Daniel Phillips wrote:
> On Thursday 05 September 2002 19:23, Steven Cole wrote:
> > I booted 2.5.33-mm3 and ran dbench with increasing
> > numbers of clients: 1,2,3,4,6,8,10,12,16,etc. while
> > running vmstat -n 1 600 from another terminal.
> >=20
> > After about 3 minutes, the output from vmstat stopped,
> > and the dbench 16 output stopped.  The machine would
> > respond to pings, but not to anything else. I had to=20
> > hard-reset the box. Nothing interesting was saved in=20
> > /var/log/messages. I have the output from vmstat if needed.
>=20
> That happened to me yesterday while hacking 2.4 and the reason was
> failed oom detection.  Memory leak?

I've seen this on 6 diffrent machines (master.kernel.org is one of
them). I have a fileserver here that hits this all the time, sometimes
as much as a few times a day.

If anyone has any ideas or patches for 2.4 I'll happily test them.

--=20
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.

--=-6RKGPRFyXIUe5eDEPWV7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9d+sKWm2vlfa207ERArB/AJ97ox6gD6f8hO6VK5ybVnnT8bhm1ACfVrko
lJT3nNxv2guBeZVVWnygxXE=
=op3T
-----END PGP SIGNATURE-----

--=-6RKGPRFyXIUe5eDEPWV7--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
