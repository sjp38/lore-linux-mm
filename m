Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 33E3E6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 20:24:33 -0500 (EST)
Message-ID: <1323048232.7454.161.camel@deadeye>
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support (was:Re:
 [BUG] 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 05 Dec 2011 01:23:52 +0000
In-Reply-To: <20111204195055.A36077AD9C@priderock.keep-cool.org>
References: 
	<OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
	 <1322664737.2755.17.camel@menhir>
	 <20111204195055.A36077AD9C@priderock.keep-cool.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rIZv2lxU9UN8BoTIhMpY"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Schafft <lion@lion.leolix.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, mike.gair@tatasteel.com, Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>


--=-rIZv2lxU9UN8BoTIhMpY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-12-04 at 20:50 +0100, Philipp Schafft wrote:
> reflum,
>=20
> On Wed, 2011-11-30 at 14:52 +0000, Steven Whitehouse wrote:
[...]
> > It is good to know that people are still using the Linux DECnet code
> > too. It has lived far beyond the time when I'd envisioned it still bein=
g
> > useful :-)
>=20
> There are still some people interested in it. Btw. on Debian popcon
> counts 5356 users.

This is grossly misleading.  Here's the historical graph showing <100
installations of libdnet until early 2011:
http://qa.debian.org/popcon-graph.php?packages=3Dlibdnet

The increase in 2011 is not a sudden resurgence of interest; it comes
from roaraudio[1] users.  For some reason (a joke?) roaraudio has DECnet
support and its packages depend on libdnet.  You can see that the above
graph is precisely correlated with this:
http://qa.debian.org/popcon-graph.php?packages=3Dlibroar1

(And so far as I can work out, libroar1 is mostly being installed as a
dependency of an unofficial package of Xine.)

The only reason I know this is because there was a sudden spate of bug
reports on the kernel due to people getting dnet-common installed as a
recommendation of libdnet and then having their Ethernet MAC addresses
reconfigured for DECnet.

[1] Yet another audio mixing daemon

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-rIZv2lxU9UN8BoTIhMpY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATtwdKOe/yOyVhhEJAQpOsQ//WOlBFMMy7cINXPzERExzfEr4s9IPGTck
uxNv6JFcqPXfq0E9kBToR6GQx/RgPG568/RIunHZbZ7GWUm62ORez2LlJhW5wLlv
o+kZEcTN3aC5+C7ubWAlbKAboMC0UPQp2CGm0lq6wKjk340BWM8wkiX5OkSjoMGs
Wkdn+XXU6dmfwWE+p4D3hD5Gp7G3jZ6EGb+uVs7Sijk3uF8CHVwMxkXBvzjhttyW
1rLW8/NOCTZFdL03xF8SZGI6jnfXYp8Y3iHVpeySh6IgoGQjGpydvjzwpsW7U+um
ZFA28NaO5LF/lrp7y2IaX1jOBowiKZB0FqybcSOYMeZoKPEf+F0SWs2dNsXSpPZG
B6aJl4EvFJxGenQ5Dd2S5zvnx3zsKapD8aGNbzTsFTwldbP2TIIEs/T7xJlYGYHc
tAR2LuhMVrhAwAO1yT1ZDnDw/GfvXEx8pUyqfYeqlvNJeNA67H4I7UzryzVzRbm2
r1lc9YeT97eLWel+dVLg0oTBUuEZTkxK+ioAKMRf13t/0RjHEbPi2doEeSCvtJ/y
T6SIKWAmiRLHit6igR8C+ofjHjQ275+ueqA8mOAZj64w1GUVOuc3NB3R5CNFLO4K
3QMwtmSaSWo6hRfdcBsU1/eCu3PNLHEToH6HjZPkkYm1GxzxnN2puYjzeGP6yY5J
ZRMsDe/FEss=
=D2v5
-----END PGP SIGNATURE-----

--=-rIZv2lxU9UN8BoTIhMpY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
