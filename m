Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 655566B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 14:50:59 -0500 (EST)
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support
	(was:Re: [BUG] 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
From: Philipp Schafft <lion@lion.leolix.org>
In-Reply-To: <1322664737.2755.17.camel@menhir>
References: 
	 <OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
	 <1322664737.2755.17.camel@menhir>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GFnK3uTMHa0v/8p0EJDa"
Date: Sun, 04 Dec 2011 20:50:52 +0100
Mime-Version: 1.0
Message-Id: <20111204195055.A36077AD9C@priderock.keep-cool.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: mike.gair@tatasteel.com, Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>


--=-GFnK3uTMHa0v/8p0EJDa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

reflum,

On Wed, 2011-11-30 at 14:52 +0000, Steven Whitehouse wrote:
> On Wed, 2011-11-30 at 13:52 +0000, mike.gair@tatasteel.com wrote:
> > In theory i'd be interested in maintaining it,
> > but i'm not sure what amount of work is involved,
> > have no experience of kernel, or where to start.
> >=20
> > Any ideas?
> >=20
> >=20
> So the issue is basically that due to there being nobody currently
> maintaining the DECnet stack, it puts a burden on the core network
> maintainers when they make cross-protocol changes, as they have to
> figure out what impact the changes are likely to have on the DECnet
> stack. So its an extra barrier to making cross-protocol code changes.
>=20
> If there was an active maintainer who could be a source of knowledge
> (and the odd patch to help out making those changes) then this issue
> would largely go away.

*nods*


> The most important duty of the maintainer is just to watch whats going
> on in the core networking development and to contribute the DECnet part
> of that. So it would be most likely be more a reviewing of patches and
> providing advice role, than one of writing patches (though it could be
> that too) and ensuring that the code continues to function correctly by
> testing it from time to time.
>=20
> The ideal maintainer would have an in-depth knowledge of the core Linux
> networking stack (socket layer, dst and neigh code), the DECnet specs
> and have a good knowledge of C.=20

I guess I would fit mostly but I have no idea of the kernel internal
stuff. Also I'm a bit short on time.


> Bearing in mind the low patch volume (almost zero, except for core
> stuff), it would probably be one of the subsystems with the least amount
> of work to do in maintaining it. So in some ways, a good intro for a new
> maintainer.

Jup. This is very true. I hope we will find a new maintainer because of
exactly this point. Maybe somebody like Mike Gair.


> I do try and keep an eye on what get submitted to the DECnet code and
> I'll continue to do that while it is still in the kernel. However, it is
> now quite a long time since I last did any substantial work in the
> networking area and things have moved on a fair bit in the mean time. I
> don't have a lot of time to review DECnet patches these days and no way
> to actually test any contributions against a real DECnet implementation.

I'm glad you are still interested. I'm always happy when I see mails
from you at the DECnet for Linux list.


> So I'll provide what help I can to anybody who wants to take the role
> on, within those limitations. I'm also happy to answer questions about
> why things were done in a particular way, for example.
>=20
> It is good to know that people are still using the Linux DECnet code
> too. It has lived far beyond the time when I'd envisioned it still being
> useful :-)

There are still some people interested in it. Btw. on Debian popcon
counts 5356 users.

--=20
Philipp.
 (Rah of PH2)

--=-GFnK3uTMHa0v/8p0EJDa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Because it's your freedom

iQEVAwUATtvPG2CSpmW8W5B8AQKLoAf/VswhaTbBgm0aKx4GIrnAJA+M5q5miQzu
HLZZ4ipepSIJbKLU3bdqvjtibQrnTYyXjov2oCLzKaizKvAKKd8blJR0CEu+dShv
xjBQiqFWfDSAARR7a3ypsyOLQ9WqG2IZdUB0FhJ0CHyjiZuHF3aJV+8/x+IZvJi7
VicP5trlrMupFQz3q74rnLmvsgCPDUmD+6mbZsYcJoAXa7V2xKMbv5245VuCaGVt
bO38Zs29XWfg51s5ULeB8CZkTlNi8h9ORxDNEF9F49KuSJygtC9jqAY353cfqZF6
fHrhL12/nFc5+aMAACFvuujDjX0luXyzQsAGDDogenWeNU03spVq3A==
=GcNW
-----END PGP SIGNATURE-----

--=-GFnK3uTMHa0v/8p0EJDa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
