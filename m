Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA6536B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:47:25 -0500 (EST)
Subject: Re: Proposed removal of DECnet support (was: Re: [BUG] 3.2-rc2:
	BUG kmalloc-8: Redzone overwritten)
From: Philipp Schafft <lion@lion.leolix.org>
In-Reply-To: <1322490161.2711.26.camel@menhir>
References: <1322490161.2711.26.camel@menhir>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QqGfpRcyUr5aTlcWKTWh"
Date: Tue, 29 Nov 2011 15:47:19 +0100
Mime-Version: 1.0
Message-Id: <20111129144720.7374B7AD9E@priderock.keep-cool.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Chrissie Caulfield <ccaulfie@redhat.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, RoarAudio <roaraudio@lists.keep-cool.org>


--=-QqGfpRcyUr5aTlcWKTWh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

reflum,

On Tue, 2011-11-29 at 15:34 +0100, Steven Whitehouse wrote:

> Has anybody actually tested it
> > >> lately against "real" DEC implementations?
> > > I doubt it :-)
> > DECnet is in use against real DEC implementations - I have checked it=20
> > quite recently against a VAX running OpenVMS. How many people are=20
> > actually using it for real work is a different question though.
> >=20
> Ok, thats useful info.

I confirmed parts of it with tcpdump and the specs some weeks ago. The
parts I worked on passed :) I also considered to send the tcpdump
upstream a patch for protocol decoding.


> > It's also true that it's not really supported by anyone as I orphaned i=
t=20
> > some time ago and nobody else seems to care enough to take it over. So=20
> > if it's becoming a burden on people doing real kernel work then I don't=
=20
> > think many tears will be wept for its removal.
> > Chrissie
>=20
> Really the only issue with keeping it around is the maintenance burden I
> think. It doesn't look like anybody wants to take it on, but maybe we
> should give it another few days for someone to speak up, just in case
> they are on holiday or something at the moment.
>=20
> Also, I've updated the subject of the thread, to make it more obvious
> what is being discussed, as well as bcc'ing it again to the DECnet list,

I'm very interested in the module. However my problem is that I had
nothing to do with kernel coding yet. However I'm currently searching a
new maintainer for it (I got info about this thread by today).
If somebody is interested in this and only needs some "motivation" or
maybe someone would like to get me into kernel coding, please just
reply :)

--=20
Philipp.
 (Rah of PH2)

--=-QqGfpRcyUr5aTlcWKTWh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Because it's your freedom

iQEVAwUATtTwd2CSpmW8W5B8AQIVnQf/bSVoNOvuLaxGDwXMmahSqdvjpjKrarjm
Q+IAHtKWKsXoYLCdaJkCuTNfoHUJujCahTiEAI4WLpgZw2nKNOOolBJREVrJZatx
mxgfYbXPU9nNC+P9DCPlX2mjDloWoivbD3jiPqU4/A/vqjl2bC2zLyP0mRxvEwGO
znwgDhO3t5y83m6jtSJgu5FQ1qwxBW8ZHtWMMPKMdwGwK9+cRY32j4itnDHa4YY9
wejjRnlHHnyzx5uH/ZwiGFRMppVsPjjQKwDv/J43UYKRls91L3CiX8L3BrRkDrMP
rMBhrxyqE/ByTfIXBQ537m6ftgxWIw1pOvEWbbHypfmbxL1wBSvkeg==
=I1G8
-----END PGP SIGNATURE-----

--=-QqGfpRcyUr5aTlcWKTWh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
