Subject: Re: NBD was Re: [PATCH 00/33] Swap over NFS -v14
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071031111800.GA2551@elf.ucw.cz>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
	 <20071030.213753.126064697.davem@davemloft.net>
	 <20071031085041.GA4362@infradead.org> <1193828206.27652.145.camel@twins>
	 <20071031111800.GA2551@elf.ucw.cz>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VKbiZubDhGRaR46ASwQd"
Date: Wed, 31 Oct 2007 12:24:49 +0100
Message-Id: <1193829889.27652.156.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

--=-VKbiZubDhGRaR46ASwQd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 12:18 +0100, Pavel Machek wrote:
> Hi!
>=20
> > > So please get the VM bits for swap over network blockdevices in first=
,
> >=20
> > Trouble with that part is that we don't have any sane network block
> > devices atm, NBD is utter crap, and iSCSI is too complex to be called
> > sane.
>=20
> Hey, NBD was designed to be _simple_. And I think it works okay in
> that area.. so can you elaborate on "utter crap"? [Ok, performance is
> not great.]

Yeah, sorry, perhaps I was overly strong.

It doesn't work for me, because:

  - it does connection management in user-space, which makes it
    impossible to reconnect. I'd want a full kernel based client.

  - it had some plugging issues, and after talking to Jens about it
    he suggested a rewrite using ->make_request() ala AoE. [ sorry if
    I'm short on details here, it was a long time ago, and I
    forgot, maybe Jens remembers ]

> Plus, I'd suggest you to look at ata-over-ethernet. It is in tree
> today, quite simple, but should have better performance than nbd.

Ah, right, I keep forgetting about that one. The only draw-back to that
on is, is that its raw ethernet, and not some IP protocol.

--=-VKbiZubDhGRaR46ASwQd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKGYBXA2jU0ANEf4RArEgAJ9xd5m8yPlfJt4Jdqej6o2YFuyIgACfUhAT
pUIM8DwgzWy7g+LhzTDdLmA=
=Cf6Y
-----END PGP SIGNATURE-----

--=-VKbiZubDhGRaR46ASwQd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
