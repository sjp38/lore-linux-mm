Subject: Re: -mm merge plans for 2.6.23
From: Zan Lynx <zlynx@acm.org>
In-Reply-To: <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8t7OLuTHXOm7C9A/1nAi"
Date: Wed, 25 Jul 2007 14:55:52 -0600
Message-Id: <1185396952.9409.5.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Rene Herman <rene.herman@gmail.com>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-8t7OLuTHXOm7C9A/1nAi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-25 at 09:02 -0700, Ray Lee wrote:

> I'd just like updatedb to amortize its work better. If we had some way
> to track all filesystem events, updatedb could keep a live and
> accurate index on the filesystem. And this isn't just updatedb that
> wants that, beagle and tracker et al also want to know filesystem
> events so that they can index the documents themselves as well as the
> metadata. And if they do it live, that spreads the cost out, including
> the VM pressure.

That would be nice.  It'd be great if there was a per-filesystem inotify
mode.  I can't help but think it'd be more efficient than recursing
every directory and adding a watch.

Or maybe a netlink thing that could buffer events since filesystem mount
until a daemon could get around to starting, so none were lost.
--=20
Zan Lynx <zlynx@acm.org>

--=-8t7OLuTHXOm7C9A/1nAi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD8DBQBGp7jYG8fHaOLTWwgRAmlUAKCTYKtHNLlZ5yFhwfMLfSi3fwlCGgCfRiJU
gYhwq7xebt1RqkKnoOdxMXM=
=5QnM
-----END PGP SIGNATURE-----

--=-8t7OLuTHXOm7C9A/1nAi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
