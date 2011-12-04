Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CB22F6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 14:55:01 -0500 (EST)
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support
	(was:Re: [BUG] 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
From: Philipp Schafft <lion@lion.leolix.org>
In-Reply-To: <OF6A1EB29A.D9A6FBAC-ON8025795A.00311C05-8025795A.0032A610@LocalDomain>
References: 
	 <OF6A1EB29A.D9A6FBAC-ON8025795A.00311C05-8025795A.0032A610@LocalDomain>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6gyiy/Yf0KLaz6yRmUEU"
Date: Sun, 04 Dec 2011 20:54:56 +0100
Mime-Version: 1.0
Message-Id: <20111204195458.65F1C7AD9C@priderock.keep-cool.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.gair@tatasteel.com
Cc: Steven Whitehouse <swhiteho@redhat.com>, Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>


--=-6gyiy/Yf0KLaz6yRmUEU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

reflum,

On Fri, 2011-12-02 at 09:14 +0000, mike.gair@tatasteel.com wrote:
> I suspect I'm not up to the job,
>=20
> - definitely not got an in-depth knowledge of the core Linux
> networking stack
> or the DECnet specs,
> Have limited, but growing experience of C, (mainly work in coral66)

I'm willing to offer you help with C and the protocol stuff. I'm the
current most active developer of the userland part.


> But I'll have a look at code/documentation
> & see if I understand any of it.=20

Ok. If you are still interested let me know if I can help you with the
above. Maybe Steven can give you some pointers for the kernel stuff.

>=20
--=20
Philipp.
 (Rah of PH2)

--=-6gyiy/Yf0KLaz6yRmUEU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Because it's your freedom

iQEVAwUATtvQD2CSpmW8W5B8AQKRWggAgW/ZdtN0m1kcTGTb9agioN8aBibc2xbi
5LOxT4IYWWoTWi+U1gEYu6a3eMCMGD3q78dEmLSXJUy0QLpU8dhfDSjGrBVDyfzF
AjFYBZyRxtOgcuESCltl4GFihCM/rJTuuyJ4rXVlAH4DWc7O7u3EvqdBgo3LS6cm
LA+8d/5UxQMeEQV6obqz7soCWg+B+sEekFkHOGxTqOOdKt30+8N2Cp/r8rm2wrPY
7Cl75M2YOtrXTTUU3BUas1tWuYIRanyI6UMZJUeQEfEvdMn7cI2pE/gAlyiN43Jv
XcCal2lbDw4P61rodIz6bJ1oun2zXnnTmNzlreouVh8ZOxX7lUaSLw==
=VQjb
-----END PGP SIGNATURE-----

--=-6gyiy/Yf0KLaz6yRmUEU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
