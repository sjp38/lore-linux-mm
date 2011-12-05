Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 19D256B0062
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 05:15:07 -0500 (EST)
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support
	(was:Re: [BUG] 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
From: Philipp Schafft <lion@lion.leolix.org>
In-Reply-To: <1323048232.7454.161.camel@deadeye>
References: 
	 <OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
	 <1322664737.2755.17.camel@menhir>
	 <20111204195055.A36077AD9C@priderock.keep-cool.org>
	 <1323048232.7454.161.camel@deadeye>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4m5XleMXEcnGSo0Wc4LW"
Date: Mon, 05 Dec 2011 11:14:58 +0100
Mime-Version: 1.0
Message-Id: <20111205101503.1DE687AD9C@priderock.keep-cool.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Steven Whitehouse <swhiteho@redhat.com>, mike.gair@tatasteel.com, Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>


--=-4m5XleMXEcnGSo0Wc4LW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

reflum,

On Mon, 2011-12-05 at 01:23 +0000, Ben Hutchings wrote:
> On Sun, 2011-12-04 at 20:50 +0100, Philipp Schafft wrote:
> > On Wed, 2011-11-30 at 14:52 +0000, Steven Whitehouse wrote:
> [...]
> > > It is good to know that people are still using the Linux DECnet code
> > > too. It has lived far beyond the time when I'd envisioned it still be=
ing
> > > useful :-)
> >=20
> > There are still some people interested in it. Btw. on Debian popcon
> > counts 5356 users.
>=20
> This is grossly misleading.  Here's the historical graph showing <100
> installations of libdnet until early 2011:
> http://qa.debian.org/popcon-graph.php?packages=3Dlibdnet

Maybe my statement was missleading. popcon shows 5356 installs. This
includes real users and non-real users. Both groups *may* be affected by
droping the kernel module (in diffrent ways).


> For some reason (a joke?) roaraudio has DECnet
> support and its packages depend on libdnet.

Maybe just because it is usefull for the RoarAudio project.

Anyway, don't take the number too important. It was just a minor note.

--=20
Philipp.
 (Rah of PH2)

--=-4m5XleMXEcnGSo0Wc4LW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Because it's your freedom

iQEVAwUATtyZomCSpmW8W5B8AQJbVgf9H9bZV2nL4Rai9Umjezw58apQQVEDJtoE
IH2Kn4GJ0ZCJgr23rtuf98e000wLcIIOJ052Ugydla/4vBp1aJF3vqd4y1ydPpnL
OF2hLDdECHmOWwVXI3ZOfnOEzhToROjvaspr0DjAC0EhopZm5jnnTpGPk5DTex0p
vW0lx/EmE6S966aROZHCjxIMBbVQM79I8ted9x5cWiFnf0N0AopLAMfXDfVDkBCn
X04FYzqv8kuAIocLKMp1HelzmN9IHa8EuJ45K4+9Rl8gAd7RaAfNWZi6iIakmjgj
KjVil1ME21LNcjhQnLMy4mOcqGBbDkASCefcuycWVpBJalvRbsaJ5g==
=3tG3
-----END PGP SIGNATURE-----

--=-4m5XleMXEcnGSo0Wc4LW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
