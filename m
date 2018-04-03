Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0C5E6B002C
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:51:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w59so8857646wrb.8
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:51:01 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id u10si1570722wrd.157.2018.04.03.01.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 01:51:00 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:50:59 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180403085059.GB3926@amd>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <1e95ce64-828b-1214-a930-1ffaedfa00b8@rasmusvillemoes.dk>
 <20180323143435.GB5624@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Content-Disposition: inline
In-Reply-To: <20180323143435.GB5624@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > And sure, your free() implementation obviously also has that property,
> > but I'm worried that they might one day decide to warn about the
> > prototype mismatch (actually, I'm surprised it doesn't warn now, given
> > that it obviously pretends to know what free() function I'm calling...),
> > or make some crazy optimization that will break stuff in very subtle wa=
ys.
> >=20
> > Also, we probably don't want people starting to use free() (or whatever
> > name is chosen) if they do know the kind of memory they're freeing?
> > Maybe it should not be advertised that widely (i.e., in kernel.h).
>=20
> All that you've said I see as an advantage, not a disadvantage.
> Maybe I should change the prototype to match the userspace
> free(), although gcc is deliberately lax about the constness of
> function arguments when determining compatibility with builtins.
> See match_builtin_function_types() if you're really curious.
>=20
> gcc already does some nice optimisations around free().  For example, it
> can eliminate dead stores:

Are we comfortable with that optimalization for kernel?

us: "Hey, let's remove those encryption keys before freeing memory."
gcc: :-).

us: "Hey, we want to erase lock magic values not to cause confusion
later."
gcc: "I like confusion!"

Yes, these probably can be fixed by strategic "volatile" and/or
barriers, but...
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrDQHMACgkQMOfwapXb+vLrSgCeNOji+4hBPeycnjBAONNSs1CB
bpoAoLiCussX5yWpsJiygcsSdM/1gXYI
=BEih
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--
