Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id A99396B0073
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:59:30 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so2153287lbo.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 09:59:28 -0700 (PDT)
Date: Mon, 22 Oct 2012 22:59:18 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121022225918.32d86a5f@sacrilege>
In-Reply-To: <1350919682.8609.877.camel@edumazet-glaptop>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
	<20121021195701.7a5872e7@sacrilege>
	<20121022004332.7e3f3f29@sacrilege>
	<20121022015134.4de457b9@sacrilege>
	<1350856053.8609.217.camel@edumazet-glaptop>
	<20121022045850.788df346@sacrilege>
	<1350893743.8609.424.camel@edumazet-glaptop>
	<20121022180655.50a50401@sacrilege>
	<1350918997.8609.858.camel@edumazet-glaptop>
	<1350919337.8609.869.camel@edumazet-glaptop>
	<1350919682.8609.877.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UxAzq4Uj91O1.bZz7APT8Ss"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/UxAzq4Uj91O1.bZz7APT8Ss
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Oct 2012 17:28:02 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-10-22 at 17:22 +0200, Eric Dumazet wrote:
> > On Mon, 2012-10-22 at 17:16 +0200, Eric Dumazet wrote:
> >=20
> > > OK, I believe I found the bug in IPv4 defrag / IPv6 reasm
> > >=20
> > > Please test the following patch.
> > >=20
> > > Thanks !
> >=20
> > I'll send a more generic patch in a few minutes, changing
> > kfree_skb_partial() to call skb_release_head_state()
> >=20
>=20
> Here it is :
>=20
...

Problem is indeed gone in v3.7-rc2 with the proposed generic patch, I
haven't read the mail in time to test the first one, but I guess it's
not relevant now that the latter one works.

Thank you for taking your time to look into the problem and actually
fix it.

I'm unclear about policies in place on the matter, but I think this
patch might be a good candidate to backport into 3.5 and 3.6 kernels,
because they seem to suffer from the issue as well.


--=20
Mike Kazantsev // fraggod.net

--Sig_/UxAzq4Uj91O1.bZz7APT8Ss
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCFe2kACgkQASbOZpzyXnFOQwCg24cpgvqGpfLm1OZEJG5EIKyB
gR8AnA7P4/bCq4VY5mtWZa5grXmKWXhS
=OqIv
-----END PGP SIGNATURE-----

--Sig_/UxAzq4Uj91O1.bZz7APT8Ss--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
