Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
From: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <3D77ED4D.B5C92504@zip.com.au>
References: <E17n25p-0006AQ-00@starship> <1031269130.5760.318.camel@tux>
	<3D77ED4D.B5C92504@zip.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-aMzRtu+riug4s6fIFNFO"
Date: 06 Sep 2002 02:09:09 +0200
Message-Id: <1031270949.5760.334.camel@tux>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Daniel Phillips <phillips@arcor.de>, Steven Cole <elenstev@mesatop.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-aMzRtu+riug4s6fIFNFO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2002-09-06 at 01:48, Andrew Morton wrote:

> > I've seen this on 6 diffrent machines (master.kernel.org is one of
> > them). I have a fileserver here that hits this all the time, sometimes
> > as much as a few times a day.
> >=20
>=20
> What have you seen?  I doubt if it's a memory leak - they tend to
> be preceded by a very obvious swapstorm.
>=20
> It seems that you have boxes which lock up, and we have no more info
> than that.
>=20
> If the machine remains pingable then yes, it may be a VM deadlock/liveloc=
k.
> We'd need to know the kernel version, system description, and a SYSRQ-T
> trace passed through ksymoops would be helpful.

They lock up, they respond to ping and accept connections. But nothing
responds in userspace. You can switch consoles and sysrq works but
otherwise they are unresponsive to keyboard input.
No kernelmessages or anything and no heavy swapout storms before lockup.

The fileserver is running 2.4.19-pre8-xfs (I've seen it with vanilla
2.4.19 aswell on other machines), Athlon 1600+, 256MB ram, 1+ TB disk
(IDE). I can't seem to find my traces right now but I know they included
references to empty_zero_page, I'll see if I can get a new trace next
time. Upgraded to 2.4.19-xfs with kdb yesterday, maybe that will give
some more info.

I've seen the same thing on my workstation (2.4.19 with ext3) a few
times, the last time it happened was when I switched tabs in galeon.

--
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.

--=-aMzRtu+riug4s6fIFNFO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9d/IkWm2vlfa207ERAk7CAJ9q9lCxNDySiwagkxelCK2+KxKtYgCbB2g+
tkxjSBgkgUj5lsAOk/mDwtI=
=yLlN
-----END PGP SIGNATURE-----

--=-aMzRtu+riug4s6fIFNFO--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
